import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/domain/printing/printing_repo.dart';

part 'printing_state.dart';

class PrintingCubit extends Cubit<PrintingState> {
  final PrintingRepo _printingRepo;
  StreamSubscription? _printerSubscription;

  PrintingCubit(this._printingRepo) : super(PrintingState());

  Future<void> startScan({ConnectionType type = ConnectionType.USB}) async {
    emit(state.copyWith(status: PrintingStatus.scanning));
    try {
      _printerSubscription?.cancel();
      _printerSubscription = _printingRepo.printersStream.listen((printers) {
        emit(state.copyWith(printers: printers));
      });
      await _printingRepo.startScan(connectionTypes: [type]);
    } catch (e) {
      emit(
        state.copyWith(
          status: PrintingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> stopScan() async {
    await _printingRepo.stopScan();
    _printerSubscription?.cancel();
    emit(state.copyWith(status: PrintingStatus.initial));
  }

  Future<void> connect(Printer printer) async {
    emit(state.copyWith(status: PrintingStatus.connecting));
    try {
      // Stop scanning before connecting as requested
      await stopScan();

      final isConnected = await _printingRepo.connect(printer);
      if (isConnected) {
        emit(
          state.copyWith(
            status: PrintingStatus.connected,
            connectedPrinter: printer,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PrintingStatus.error,
            errorMessage: "Failed to connect",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PrintingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> disconnect() async {
    if (state.connectedPrinter != null) {
      await _printingRepo.disconnect(state.connectedPrinter!);
      emit(
        state.copyWith(status: PrintingStatus.initial, connectedPrinter: null),
      );
    }
  }

  @override
  Future<void> close() {
    _printerSubscription?.cancel();
    return super.close();
  }
}
