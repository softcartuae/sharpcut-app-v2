import 'package:flutter_thermal_printer/utils/printer.dart';

abstract class PrintingRepo {
  Stream<List<Printer>> get printersStream;
  Future<void> startScan({List<ConnectionType>? connectionTypes});
  Future<void> stopScan();
  Future<bool> connect(Printer printer);
  Future<void> disconnect(Printer printer);
}
