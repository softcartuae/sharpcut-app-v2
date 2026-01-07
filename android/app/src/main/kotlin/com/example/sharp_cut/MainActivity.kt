package com.example.sharp_cut

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.*
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.sharp_cut/usb_printer"
    private val ACTION_USB_PERMISSION = "com.example.sharp_cut.USB_PERMISSION"

    private lateinit var usbManager: UsbManager
    private var usbConnection: UsbDeviceConnection? = null
    private var usbInterface: UsbInterface? = null
    private var usbEndpoint: UsbEndpoint? = null

    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "getUsbDevices" -> {
                    result.success(getUsbDevices())
                }

                "connect" -> {
                    val vendorId = call.argument<Int>("vendorId")
                    val productId = call.argument<Int>("productId")

                    if (vendorId == null || productId == null) {
                        result.error("INVALID_ARGS", "vendorId or productId missing", null)
                        return@setMethodCallHandler
                    }

                    connectToDevice(vendorId, productId, result)
                }

                "print" -> {
                    val data = call.argument<ByteArray>("data")
                    if (data == null) {
                        result.error("INVALID_ARGS", "Print data missing", null)
                        return@setMethodCallHandler
                    }

                    result.success(printData(data))
                }

                "disconnect" -> {
                    disconnect()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        val filter = IntentFilter(ACTION_USB_PERMISSION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(usbReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(usbReceiver, filter)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(usbReceiver)
        } catch (_: Exception) {}
        disconnect()
    }

    // -------------------------------------------------------------------------
    // USB LOGIC
    // -------------------------------------------------------------------------

    private fun getUsbDevices(): List<Map<String, Any>> {
        val list = ArrayList<Map<String, Any>>()
        usbManager.deviceList.values.forEach { device ->
            list.add(
                mapOf(
                    "name" to (device.productName ?: "Unknown"),
                    "vendorId" to device.vendorId,
                    "productId" to device.productId
                )
            )
        }
        return list
    }

    private fun connectToDevice(
        vendorId: Int,
        productId: Int,
        result: MethodChannel.Result
    ) {
        val device = usbManager.deviceList.values.find {
            it.vendorId == vendorId && it.productId == productId
        }

        if (device == null) {
            result.error("DEVICE_NOT_FOUND", "USB device not found", null)
            return
        }

        if (usbManager.hasPermission(device)) {
            openDevice(device, result)
        } else {
            pendingPermissionResult = result

            val intent = Intent(ACTION_USB_PERMISSION).apply {
                setPackage(packageName) // explicit intent (important)
            }

            val permissionIntent = PendingIntent.getBroadcast(
                this,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE
            )

            usbManager.requestPermission(device, permissionIntent)
        }
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action != ACTION_USB_PERMISSION) return

            val device =
                intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)

            val granted =
                intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)

            if (granted && device != null) {
                pendingPermissionResult?.let {
                    openDevice(device, it)
                }
            } else {
                pendingPermissionResult?.error(
                    "PERMISSION_DENIED",
                    "USB permission denied",
                    null
                )
            }

            pendingPermissionResult = null
        }
    }

    private fun openDevice(device: UsbDevice, result: MethodChannel.Result) {
        try {
            var foundInterface: UsbInterface? = null
            var foundEndpoint: UsbEndpoint? = null

            for (i in 0 until device.interfaceCount) {
                val iface = device.getInterface(i)
                for (j in 0 until iface.endpointCount) {
                    val ep = iface.getEndpoint(j)
                    if (ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK &&
                        ep.direction == UsbConstants.USB_DIR_OUT
                    ) {
                        foundInterface = iface
                        foundEndpoint = ep
                        break
                    }
                }
                if (foundInterface != null) break
            }

            if (foundInterface == null || foundEndpoint == null) {
                result.error("NO_ENDPOINT", "No BULK OUT endpoint found", null)
                return
            }

            val connection = usbManager.openDevice(device)
            if (connection == null) {
                result.error("CONNECTION_FAILED", "Unable to open USB device", null)
                return
            }

            if (!connection.claimInterface(foundInterface, true)) {
                connection.close()
                result.error("CLAIM_FAILED", "Could not claim USB interface", null)
                return
            }

            usbConnection = connection
            usbInterface = foundInterface
            usbEndpoint = foundEndpoint

            result.success(true)

        } catch (e: Exception) {
            result.error("USB_ERROR", e.message, null)
        }
    }

    private fun printData(data: ByteArray): Boolean {
        val conn = usbConnection ?: return false
        val ep = usbEndpoint ?: return false
        return conn.bulkTransfer(ep, data, data.size, 5000) >= 0
    }

    private fun disconnect() {
        try {
            usbConnection?.releaseInterface(usbInterface)
            usbConnection?.close()
        } catch (_: Exception) {}
        usbConnection = null
        usbInterface = null
        usbEndpoint = null
    }
}
