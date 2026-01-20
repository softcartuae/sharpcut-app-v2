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
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import java.net.Socket
import java.io.OutputStream
import java.util.UUID

class MainActivity : FlutterActivity() {

    private val USB_CHANNEL = "com.example.sharp_cut/usb_printer"
    private val BLUETOOTH_CHANNEL = "com.example.sharp_cut/bluetooth_printer"
    private val NETWORK_CHANNEL = "com.example.sharp_cut/network_printer"
    private val EVENT_CHANNEL = "com.example.sharp_cut/printer_status"
    
    private val ACTION_USB_PERMISSION = "com.example.sharp_cut.USB_PERMISSION"

    // USB Variables
    private lateinit var usbManager: UsbManager
    private var usbConnection: UsbDeviceConnection? = null
    private var connectedUsbDevice: UsbDevice? = null
    private var usbInterface: UsbInterface? = null
    private var usbEndpoint: UsbEndpoint? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    // Bluetooth Variables
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private var bluetoothSocket: BluetoothSocket? = null
    private val SPP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    // Network Variables
    private var networkSocket: Socket? = null
    private var networkOutputStream: OutputStream? = null

    private var eventSink: io.flutter.plugin.common.EventChannel.EventSink? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager

        // USB Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USB_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsbDevices" -> result.success(getUsbDevices())
                "connect" -> {
                    val vendorId = call.argument<Int>("vendorId")
                    val productId = call.argument<Int>("productId")
                    if (vendorId == null || productId == null) {
                        result.error("INVALID_ARGS", "vendorId or productId missing", null)
                    } else {
                        connectToUsbDevice(vendorId, productId, result)
                    }
                }
                "print" -> {
                    val data = call.argument<ByteArray>("data")
                    if (data == null) result.error("INVALID_ARGS", "Print data missing", null)
                    else result.success(printUsbData(data))
                }
                "disconnect" -> {
                    disconnectUsb()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Bluetooth Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBluetoothDevices" -> result.success(getBluetoothDevices())
                "connect" -> {
                    val address = call.argument<String>("address")
                    if (address == null) result.error("INVALID_ARGS", "Address missing", null)
                    else connectToBluetoothDevice(address, result)
                }
                "print" -> {
                    val data = call.argument<ByteArray>("data")
                    if (data == null) result.error("INVALID_ARGS", "Print data missing", null)
                    else printBluetoothData(data, result)
                }
                "disconnect" -> {
                    disconnectBluetooth()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Network Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NETWORK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scan" -> {
                     // Basic subnet scan could be implemented here, but for now we'll return empty
                     // or implement a simple ping scan if needed. 
                     // For this iteration, we focus on connect/print.
                     result.success(emptyList<Map<String, Any>>())
                }
                "connect" -> {
                    val ip = call.argument<String>("ipAddress")
                    val port = call.argument<Int>("port") ?: 9100
                    if (ip == null) result.error("INVALID_ARGS", "IP Address missing", null)
                    else connectToNetworkDevice(ip, port, result)
                }
                "print" -> {
                    val data = call.argument<ByteArray>("data")
                    if (data == null) result.error("INVALID_ARGS", "Print data missing", null)
                    else printNetworkData(data, result)
                }
                "disconnect" -> {
                    disconnectNetwork()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Event Channel for Status Updates
        io.flutter.plugin.common.EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : io.flutter.plugin.common.EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: io.flutter.plugin.common.EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        val filter = IntentFilter(ACTION_USB_PERMISSION)
        filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(usbReceiver, filter, Context.RECEIVER_EXPORTED)
            registerReceiver(disconnectionReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(usbReceiver, filter)
            registerReceiver(disconnectionReceiver, filter)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(usbReceiver)
        } catch (_: Exception) {}
        disconnectUsb()
        disconnectBluetooth()
        disconnectNetwork()
        try {
            unregisterReceiver(disconnectionReceiver)
        } catch (_: Exception) {}
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

    private fun connectToUsbDevice(vendorId: Int, productId: Int, result: MethodChannel.Result) {
        val device = usbManager.deviceList.values.find {
            it.vendorId == vendorId && it.productId == productId
        }

        if (device == null) {
            result.error("DEVICE_NOT_FOUND", "USB device not found", null)
            return
        }

        if (usbManager.hasPermission(device)) {
            openUsbDevice(device, result)
        } else {
            pendingPermissionResult = result
            val intent = Intent(ACTION_USB_PERMISSION).apply {
                setPackage(packageName)
            }
            val permissionIntent = PendingIntent.getBroadcast(
                this, 0, intent, PendingIntent.FLAG_IMMUTABLE
            )
            usbManager.requestPermission(device, permissionIntent)
        }
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action != ACTION_USB_PERMISSION) return
            val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
            val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
            if (granted && device != null) {
                pendingPermissionResult?.let { openUsbDevice(device, it) }
            } else {
                pendingPermissionResult?.error("PERMISSION_DENIED", "USB permission denied", null)
            }
            pendingPermissionResult = null
        }
    }

    private val disconnectionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                    if (device != null && connectedUsbDevice != null) {
                        if (device.deviceId == connectedUsbDevice?.deviceId) {
                            disconnectUsb()
                            runOnUiThread {
                                eventSink?.success(mapOf("status" to "disconnected", "type" to "USB"))
                            }
                        }
                    }
                }
                BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                    val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                    if (device != null && bluetoothSocket != null) {
                        if (device.address == bluetoothSocket?.remoteDevice?.address) {
                            disconnectBluetooth()
                            runOnUiThread {
                                eventSink?.success(mapOf("status" to "disconnected", "type" to "BLE"))
                            }
                        }
                    }
                }
            }
        }
    }

    private fun openUsbDevice(device: UsbDevice, result: MethodChannel.Result) {
        try {
            var foundInterface: UsbInterface? = null
            var foundEndpoint: UsbEndpoint? = null

            for (i in 0 until device.interfaceCount) {
                val iface = device.getInterface(i)
                for (j in 0 until iface.endpointCount) {
                    val ep = iface.getEndpoint(j)
                    if (ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK && ep.direction == UsbConstants.USB_DIR_OUT) {
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
            connectedUsbDevice = device
            result.success(true)

        } catch (e: Exception) {
            result.error("USB_ERROR", e.message, null)
        }
    }

    private fun printUsbData(data: ByteArray): Boolean {
        val conn = usbConnection ?: return false
        val ep = usbEndpoint ?: return false
        return conn.bulkTransfer(ep, data, data.size, 5000) >= 0
    }

    private fun disconnectUsb() {
        try {
            usbConnection?.releaseInterface(usbInterface)
            usbConnection?.close()
        } catch (_: Exception) {}
        usbConnection = null
        usbInterface = null
        usbEndpoint = null
        connectedUsbDevice = null
    }

    // -------------------------------------------------------------------------
    // BLUETOOTH LOGIC
    // -------------------------------------------------------------------------

    private fun getBluetoothDevices(): List<Map<String, Any>> {
        val list = ArrayList<Map<String, Any>>()
        if (bluetoothAdapter == null) return list
        
        try {
            val pairedDevices = bluetoothAdapter.bondedDevices
            pairedDevices.forEach { device ->
                list.add(
                    mapOf(
                        "name" to (device.name ?: "Unknown"),
                        "address" to device.address
                    )
                )
            }
        } catch (e: SecurityException) {
            // Handle permission error
        }
        return list
    }

    private fun connectToBluetoothDevice(address: String, result: MethodChannel.Result) {
        Thread {
            try {
                val device = bluetoothAdapter?.getRemoteDevice(address)
                if (device == null) {
                    runOnUiThread { result.error("DEVICE_NOT_FOUND", "Bluetooth device not found", null) }
                    return@Thread
                }

                try { bluetoothAdapter?.cancelDiscovery() } catch (e: SecurityException) {}

                val socket = device.createRfcommSocketToServiceRecord(SPP_UUID)
                try {
                    socket.connect()
                } catch (e: SecurityException) {
                     runOnUiThread { result.error("PERMISSION_DENIED", "Bluetooth permission missing", null) }
                     return@Thread
                }
                
                bluetoothSocket = socket
                runOnUiThread { result.success(true) }
            } catch (e: Exception) {
                runOnUiThread { result.error("CONNECTION_FAILED", e.message, null) }
            }
        }.start()
    }

    private fun printBluetoothData(data: ByteArray, result: MethodChannel.Result) {
        Thread {
            try {
                val socket = bluetoothSocket
                if (socket == null || !socket.isConnected) {
                    runOnUiThread { result.error("NOT_CONNECTED", "Bluetooth not connected", null) }
                    return@Thread
                }
                socket.outputStream.write(data)
                socket.outputStream.flush()
                runOnUiThread { result.success(true) }
            } catch (e: Exception) {
                runOnUiThread { result.error("PRINT_ERROR", e.message, null) }
            }
        }.start()
    }

    private fun disconnectBluetooth() {
        try {
            bluetoothSocket?.close()
        } catch (_: Exception) {}
        bluetoothSocket = null
    }

    // -------------------------------------------------------------------------
    // NETWORK LOGIC
    // -------------------------------------------------------------------------

    private fun connectToNetworkDevice(ip: String, port: Int, result: MethodChannel.Result) {
        Thread {
            try {
                val socket = Socket()
                socket.connect(java.net.InetSocketAddress(ip, port), 5000) // 5s timeout
                networkSocket = socket
                networkOutputStream = socket.getOutputStream()
                runOnUiThread { result.success(true) }
            } catch (e: Exception) {
                runOnUiThread { result.error("CONNECTION_FAILED", e.message, null) }
            }
        }.start()
    }

    private fun printNetworkData(data: ByteArray, result: MethodChannel.Result) {
        Thread {
            try {
                val stream = networkOutputStream
                if (stream == null || networkSocket?.isConnected != true) {
                    runOnUiThread { result.error("NOT_CONNECTED", "Network printer not connected", null) }
                    return@Thread
                }
                stream.write(data)
                stream.flush()
                runOnUiThread { result.success(true) }
            } catch (e: Exception) {
                runOnUiThread { result.error("PRINT_ERROR", e.message, null) }
            }
        }.start()
    }

    private fun disconnectNetwork() {
        try {
            networkOutputStream?.close()
            networkSocket?.close()
        } catch (_: Exception) {}
        networkOutputStream = null
        networkSocket = null
    }
}
