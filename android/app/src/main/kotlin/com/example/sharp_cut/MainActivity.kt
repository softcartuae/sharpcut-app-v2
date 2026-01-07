package com.example.sharp_cut

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sharp_cut/usb_printer"
    private val ACTION_USB_PERMISSION = "com.example.sharp_cut.USB_PERMISSION"
    
    private var usbManager: UsbManager? = null
    private var usbConnection: UsbDeviceConnection? = null
    private var usbInterface: UsbInterface? = null
    private var usbEndpoint: UsbEndpoint? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsbDevices" -> {
                    val devices = getUsbDevices()
                    result.success(devices)
                }
                "connect" -> {
                    val vendorId = call.argument<Int>("vendorId")
                    val productId = call.argument<Int>("productId")
                    if (vendorId != null && productId != null) {
                        connectToDevice(vendorId, productId, result)
                    } else {
                        result.error("INVALID_ARGS", "VendorId or ProductId missing", null)
                    }
                }
                "print" -> {
                    val data = call.argument<ByteArray>("data")
                    if (data != null) {
                        val success = printData(data)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGS", "Data missing", null)
                    }
                }
                "disconnect" -> {
                    disconnect()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Register BroadcastReceiver for USB permission
        val filter = IntentFilter(ACTION_USB_PERMISSION)
        registerReceiver(usbReceiver, filter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(usbReceiver)
        disconnect()
    }

    private fun getUsbDevices(): List<Map<String, Any>> {
        val deviceList = ArrayList<Map<String, Any>>()
        val devices = usbManager?.deviceList
        devices?.values?.forEach { device ->
            val deviceMap = HashMap<String, Any>()
            deviceMap["name"] = device.productName ?: "Unknown Device"
            deviceMap["vendorId"] = device.vendorId
            deviceMap["productId"] = device.productId
            deviceList.add(deviceMap)
        }
        return deviceList
    }

    private fun connectToDevice(vendorId: Int, productId: Int, result: MethodChannel.Result) {
        val device = usbManager?.deviceList?.values?.find { 
            it.vendorId == vendorId && it.productId == productId 
        }

        if (device == null) {
            result.error("DEVICE_NOT_FOUND", "Device not found", null)
            return
        }

        if (usbManager?.hasPermission(device) == true) {
            openDevice(device, result)
        } else {
            pendingPermissionResult = result
            val permissionIntent = PendingIntent.getBroadcast(
                this, 0, Intent(ACTION_USB_PERMISSION), 
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
            )
            usbManager?.requestPermission(device, permissionIntent)
        }
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (ACTION_USB_PERMISSION == intent.action) {
                synchronized(this) {
                    val device: UsbDevice? = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        device?.apply {
                            pendingPermissionResult?.let { openDevice(this, it) }
                        }
                    } else {
                        pendingPermissionResult?.error("PERMISSION_DENIED", "USB permission denied", null)
                    }
                    pendingPermissionResult = null
                }
            }
        }
    }

    private fun openDevice(device: UsbDevice, result: MethodChannel.Result) {
        try {
            // Find the correct interface and endpoint
            var intf: UsbInterface? = null
            var ep: UsbEndpoint? = null

            for (i in 0 until device.interfaceCount) {
                val iface = device.getInterface(i)
                // Look for Printer class (7) or generic vendor specific
                // Most thermal printers use class 7, but some might be vendor specific (255)
                // We'll look for bulk endpoints
                for (j in 0 until iface.endpointCount) {
                    val endpoint = iface.getEndpoint(j)
                    if (endpoint.type == UsbConstants.USB_ENDPOINT_XFER_BULK &&
                        endpoint.direction == UsbConstants.USB_DIR_OUT) {
                        intf = iface
                        ep = endpoint
                        break
                    }
                }
                if (intf != null) break
            }

            if (intf == null || ep == null) {
                result.error("NO_ENDPOINT", "No suitable printing endpoint found", null)
                return
            }

            val connection = usbManager?.openDevice(device)
            if (connection == null) {
                result.error("CONNECTION_FAILED", "Failed to open device connection", null)
                return
            }

            if (connection.claimInterface(intf, true)) {
                usbConnection = connection
                usbInterface = intf
                usbEndpoint = ep
                result.success(true)
            } else {
                connection.close()
                result.error("CLAIM_FAILED", "Failed to claim interface", null)
            }
        } catch (e: Exception) {
            result.error("EXCEPTION", e.message, null)
        }
    }

    private fun printData(data: ByteArray): Boolean {
        val conn = usbConnection ?: return false
        val ep = usbEndpoint ?: return false
        
        // Bulk transfer
        // Timeout 5000ms
        val bytesTransferred = conn.bulkTransfer(ep, data, data.size, 5000)
        return bytesTransferred >= 0
    }

    private fun disconnect() {
        try {
            usbConnection?.releaseInterface(usbInterface)
            usbConnection?.close()
        } catch (e: Exception) {
            // Ignore errors on close
        }
        usbConnection = null
        usbInterface = null
        usbEndpoint = null
    }
}
