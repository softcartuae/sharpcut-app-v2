import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/printing/printing_repo.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

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
      await _printingRepo.stopScan();
      _printerSubscription?.cancel();

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
      log(e.toString());
      emit(
        state.copyWith(
          status: PrintingStatus.error,
          errorMessage: "Failed to connect",
        ),
      );
    }
  }

  Future<void> disconnect() async {
    if (state.connectedPrinter != null) {
      emit(state.copyWith(status: PrintingStatus.disconnecting));
      try {
        await _printingRepo.disconnect(state.connectedPrinter!);
      } catch (e) {
        // Ignore error and clear state
      }
      emit(
        state.copyWith(status: PrintingStatus.initial, connectedPrinter: null),
      );
    }
  }

  Future<void> printInvoice({
    required SettlePaymentRequestModel request,
    required ShopModel shopData,
    required List<CartItemModel> cartItems,
    required String? staffName,
    required String? invoiceNumber,
    required String? bookingTime,
  }) async {
    if (state.connectedPrinter == null) {
      ToastHelper.showError("No printer connected");
      emit(
        state.copyWith(
          status: PrintingStatus.error,
          errorMessage: "No printer connected",
        ),
      );
      return;
    }

    emit(state.copyWith(status: PrintingStatus.printing));
    try {
      await _printingRepo.printInvoice(
        printer: state.connectedPrinter!,
        request: request,
        shopData: shopData,
        cartItems: cartItems,
        staffName: staffName,
        invoiceNumber: invoiceNumber,
        bookingTime: bookingTime,
      );
      emit(state.copyWith(status: PrintingStatus.printed));
    } catch (e) {
      log(e.toString());
      emit(
        state.copyWith(
          status: PrintingStatus.error,
          errorMessage: "Failed to print: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> printQuickReport({required QuickReportModel report}) async {
    if (state.connectedPrinter == null) {
      ToastHelper.showError("No printer connected");
      emit(
        state.copyWith(
          status: PrintingStatus.error,
          errorMessage: "No printer connected",
        ),
      );
      return;
    }

    emit(state.copyWith(status: PrintingStatus.printing));
    try {
      await _printingRepo.printQuickReport(
        printer: state.connectedPrinter!,
        report: report,
      );
      emit(state.copyWith(status: PrintingStatus.printed));
    } catch (e) {
      log(e.toString());
      emit(
        state.copyWith(
          status: PrintingStatus.error,
          errorMessage: "Failed to print: ${e.toString()}",
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _printerSubscription?.cancel();
    return super.close();
  }
}
