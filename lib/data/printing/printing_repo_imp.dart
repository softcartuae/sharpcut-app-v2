import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/domain/printing/printing_repo.dart';

class PrintingRepoImp implements PrintingRepo {
  final FlutterThermalPrinter _printer = FlutterThermalPrinter.instance;

  @override
  Stream<List<Printer>> get printersStream => _printer.devicesStream;

  @override
  Future<void> startScan({List<ConnectionType>? connectionTypes}) async {
    await _printer.getPrinters(
      connectionTypes: connectionTypes ?? [ConnectionType.USB],
    );
  }

  @override
  Future<void> stopScan() async {
    // No explicit stop scan needed for USB usually, but keeping interface consistent
  }

  @override
  Future<bool> connect(Printer printer) async {
    return await _printer.connect(printer);
  }

  @override
  Future<void> disconnect(Printer printer) async {
    await _printer.disconnect(printer);
  }
}
