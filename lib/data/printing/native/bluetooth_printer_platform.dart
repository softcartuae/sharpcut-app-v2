import 'dart:async';
import 'package:flutter/services.dart';

class BluetoothPrinterPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.example.sharp_cut/bluetooth_printer',
  );

  /// Returns a list of paired Bluetooth devices.
  /// Each device is a Map with keys: "name", "address".
  Future<List<Map<String, dynamic>>> getBluetoothDevices() async {
    final List<dynamic>? devices = await _channel.invokeMethod(
      'getBluetoothDevices',
    );
    if (devices == null) return [];

    return devices.map((device) {
      final Map<Object?, Object?> map = device as Map<Object?, Object?>;
      return map.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  /// Connects to a Bluetooth device by MAC address.
  /// Returns true if connection was successful.
  Future<bool> connect(String macAddress) async {
    final bool? result = await _channel.invokeMethod('connect', {
      'address': macAddress,
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
