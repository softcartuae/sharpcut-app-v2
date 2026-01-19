import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class UsbPrinterPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.example.sharp_cut/usb_printer',
  );

  /// Returns a list of connected USB devices.
  /// Each device is a Map with keys: "name", "vendorId", "productId".
  Future<List<Map<String, dynamic>>> getUsbDevices() async {
    final List<dynamic>? devices = await _channel.invokeMethod('getUsbDevices');
    if (devices == null) return [];

    return devices.map((device) {
      final Map<Object?, Object?> map = device as Map<Object?, Object?>;
      return map.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  /// Connects to a USB device by vendorId and productId.
  /// Returns true if connection (and permission) was successful.
  Future<bool> connect(int vendorId, int productId) async {
    final bool? result = await _channel.invokeMethod('connect', {
      'vendorId': vendorId,
      'productId': productId,
    });
    return result ?? false;
  }

  /// Prints raw bytes to the connected printer.
  Future<bool> print(Uint8List data) async {
    final bool? result = await _channel.invokeMethod('print', {'data': data});
    return result ?? false;
  }

  /// Disconnects the current printer.
  Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }
}
