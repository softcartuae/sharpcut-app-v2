enum ConnectionType { USB, BLE, BLUETOOTH, NETWORK }

class Printer {
  final String? name;
  final String? address;
  final String? vendorId;
  final String? productId;
  final String? deviceId;
  final ConnectionType connectionType;

  Printer({
    this.name,
    this.address,
    this.vendorId,
    this.productId,
    this.deviceId,
    this.connectionType = ConnectionType.USB,
  });
}
