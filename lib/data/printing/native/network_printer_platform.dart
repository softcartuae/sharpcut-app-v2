import 'dart:async';
import 'package:flutter/services.dart';

class NetworkPrinterPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.example.sharp_cut/network_printer',
  );

  /// Scans for devices on the network.
  /// Currently, this might just return a dummy list or rely on manual IP entry
  /// as full network scanning can be slow/complex.
  /// For now, we'll implement a basic subnet scan on the native side if requested,
  /// or just rely on direct connection.
  /// Let's assume we might want to scan.
  Future<List<Map<String, dynamic>>> scan(String? subnet) async {
    final List<dynamic>? devices = await _channel.invokeMethod('scan', {
      'subnet': subnet,
    });
    if (devices == null) return [];

    return devices.map((device) {
      final Map<Object?, Object?> map = device as Map<Object?, Object?>;
      return map.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  /// Connects to a Network device by IP and Port.
  /// Returns true if connection was successful.
  Future<bool> connect(String ipAddress, int port) async {
    final bool? result = await _channel.invokeMethod('connect', {
      'ipAddress': ipAddress,
      'port': port,
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
