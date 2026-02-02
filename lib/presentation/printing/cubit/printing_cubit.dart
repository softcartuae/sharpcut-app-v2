import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/printing/model/printer_settings_model.dart';
import 'package:sharp_cut/domain/printing/printing_repo.dart';
import 'package:sharp_cut/domain/printing/model/printer_paper_size.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:sharp_cut/domain/printing/model/server_printer.dart';

part 'printing_state.dart';

class PrintingCubit extends Cubit<PrintingState> {
  final PrintingRepo _printingRepo;
  StreamSubscription? _printerSubscription;
  StreamSubscription? _statusSubscription;
  Timer? _heartbeatTimer;

  PrintingCubit(this._printingRepo) : super(PrintingState()) {
    loadPrinterSettings();
    _listenToPrinterStatus();
    getPrintingMode();
    getPaperSize();
    _tryAutoConnect();
  }

  void _listenToPrinterStatus() {
    _statusSubscription = _printingRepo.statusStream.listen((event) {
      if (event['status'] == 'disconnected') {
        disconnect();
        ToastHelper.showError("Printer disconnected");
      }
    });
  }

  Future<void> startScan({ConnectionType type = ConnectionType.USB}) async {
    emit(state.copyWith(status: PrintingStatus.scanning, scanningType: type));
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
          scanningType: null,
        ),
      );
    }
  }

  Future<void> stopScan() async {
    await _printingRepo.stopScan();
    _printerSubscription?.cancel();
    emit(state.copyWith(status: PrintingStatus.initial, scanningType: null));
  }

  Future<void> connect(Printer printer) async {
    emit(state.copyWith(status: PrintingStatus.connecting));
    try {
      // Stop scanning before connecting as requested
      await _printingRepo.stopScan();
      _printerSubscription?.cancel();

      final isConnected = await _printingRepo.connect(printer);
      if (isConnected) {
        final hasPaperSize = await _printingRepo.hasPaperSize();
        emit(
          state.copyWith(
            status: PrintingStatus.connected,
            connectedPrinter: printer,
            showPaperSizeDialog: !hasPaperSize,
          ),
        );
        _printingRepo.saveLastConnectedPrinter(printer);
        _startHeartbeat();
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
        emit(
          state.copyWith(
            status: PrintingStatus.initial,
            connectedPrinter: null,
            clearConnectedPrinter: true,
          ),
        );
        _stopHeartbeat();
        _printingRepo.clearLastConnectedPrinter();
      } catch (e) {
        emit(
          state.copyWith(
            status: PrintingStatus.initial,
            connectedPrinter: null,
            clearConnectedPrinter: true,
          ),
        );
      }
    }
  }

  void selectServerPrinter(ServerPrinter printer) {
    _printingRepo.saveSelectedServerPrinter(printer);
    emit(state.copyWith(selectedServerPrinter: printer));
  }

  Future<void> printInvoice({
    required SettlePaymentRequestModel request,
    required ShopModel shopData,
    required List<CartItemModel> cartItems,
    required double balanceAmount,
    required String? staffName,
    required String? invoiceNumber,
    required String? bookingTime,
    required String? invoiceDate,
    required int? printCount,
    required int? chairId,
    String? endTime,
  }) async {

    if (state.isServerPrinting) {
      if (state.selectedServerPrinter == null) {
        ToastHelper.showError("Please select a server printer");
        return;
      }

      if (state.currentPaperSize == null) {
        ToastHelper.showError("Please select a paper size");
        return;
      }

      emit(state.copyWith(status: PrintingStatus.printing));
      final result = await _printingRepo.printServerPrinter(
        transactionId: request.transactionId!,
        printerName: state.selectedServerPrinter!.name!,
        size: state.currentPaperSize!.widthInPixels,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(status: PrintingStatus.error, errorMessage: failure),
          );
          ToastHelper.showError("Printing failed");
        },
        (_) {
          emit(state.copyWith(status: PrintingStatus.printed));
          ToastHelper.showSuccess(
            "Printing from server: ${state.selectedServerPrinter?.name}",
          );
        },
      );
      return;
    }


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
      final bool openDrawer = _shouldOpenDrawer(request);
      await _printingRepo.printInvoice(
        chairId: chairId,
        printer: state.connectedPrinter!,
        request: request,
        shopData: shopData,
        balanceAmount: balanceAmount,
        cartItems: cartItems,
        staffName: staffName,
        invoiceNumber: invoiceNumber,
        bookingTime: bookingTime,
        invoiceDate: invoiceDate,
        endTime: endTime,
        copies: printCount ?? 1,
        openDrawer: openDrawer,
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

  Future<void> printQuickReport({
    required QuickReportModel report,
    required int? printCount,
    int? userId,
  }) async {
    if (state.isServerPrinting) {
      if (state.selectedServerPrinter == null) {
        ToastHelper.showError("Please select a server printer");
        return;
      }

      if (state.currentPaperSize == null) {
        ToastHelper.showError("Please select a paper size");
        return;
      }

      emit(state.copyWith(status: PrintingStatus.printing));
      final result = await _printingRepo.printQuickReportServer(
        dateRange: report.dateRange,
        userId: userId,
        printerName: state.selectedServerPrinter!.name!,
        size: state.currentPaperSize!.widthInPixels,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(status: PrintingStatus.error, errorMessage: failure),
          );
          ToastHelper.showError("Printing failed");
        },
        (_) {
          emit(state.copyWith(status: PrintingStatus.printed));
          ToastHelper.showSuccess(
            "Printing from server: ${state.selectedServerPrinter?.name}",
          );
        },
      );
      return;
    }

    if (state.connectedPrinter == null) {
      log("No printer connected");
      // ToastHelper.showError("No printer connected");
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
        copies: printCount ?? 1,
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

  Future<void> printCloseRegisterReport({
    required CloseRegisterReportModel report,
    required ShopModel shop,
    required int? printCount,
  }) async {
    if (state.isServerPrinting) {
      if (state.selectedServerPrinter == null) {
        ToastHelper.showError("Please select a server printer");
        return;
      }

      if (state.currentPaperSize == null) {
        ToastHelper.showError("Please select a paper size");
        return;
      }

      emit(state.copyWith(status: PrintingStatus.printing));
      final result = await _printingRepo.printCashRegisterReportServer(
        cashRegisterId: report.cashRegisterId,
        printerName: state.selectedServerPrinter!.name!,
        size: state.currentPaperSize!.widthInPixels,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(status: PrintingStatus.error, errorMessage: failure),
          );
          ToastHelper.showError("Printing failed");
        },
        (_) {
          emit(state.copyWith(status: PrintingStatus.printed));
          ToastHelper.showSuccess(
            "Printing from server: ${state.selectedServerPrinter?.name}",
          );
        },
      );
      return;
    }

    if (state.connectedPrinter == null) {
      ToastHelper.showError("No printer connected");
      log("No printer connected printign ");
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
      await _printingRepo.printCloseRegisterReport(
        printer: state.connectedPrinter!,
        report: report,
        shop: shop,
        copies: printCount ?? 1,
      );
      emit(state.copyWith(status: PrintingStatus.printed));
    } catch (e) {
      log(e.toString());
      emit(
        state.copyWith(
          status: PrintingStatus.error,
          errorMessage: "Failed to print",
        ),
      );
    }
  }

  Future<void> loadPrinterSettings() async {
    try {
      emit(state.copyWith(isLoading: true));
      final result = await _printingRepo.getPrinterSettings();
      result.fold(
        (failure) {
          log(failure);
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: "Failed to fetch printer settings",
            ),
          );
        },
        (settings) {
          emit(state.copyWith(settings: settings, isLoading: false));
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updatePrinterSettings(PrinterSettingsModel model) async {
    // Optimistic Update: Update UI immediately
    final oldSettings = state.settings;
    emit(state.copyWith(settings: model, isLoading: true));

    final result = await _printingRepo.updatePrinterSettings(model);
    result.fold(
      (failure) {
        log(failure);
        // Revert to old settings on failure
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: "Failed to update printer settings",
            settings: oldSettings,
          ),
        );
        ToastHelper.showError(failure);
      },
      (_) async {
        // Success: We can either keep the optimistic state or reload.
        // Reloading ensures we are in sync with server, but the UI is already correct.
        await loadPrinterSettings();
        ToastHelper.showSuccess("Printer settings updated successfully");
      },
    );
  }

  bool _shouldOpenDrawer(SettlePaymentRequestModel request) {
    if (state.settings == null) return false;

    if (request.mode != null) {
      if (state.settings!.openDrawer.cash &&
          request.mode!.any((m) => m.toLowerCase().contains('cash'))) {
        return true;
      }
      if (state.settings!.openDrawer.card &&
          request.mode!.any((m) => m.toLowerCase().contains('card'))) {
        return true;
      }
    }
    return false;
  }

  // Removed old loadPrinterSettings and savePrinterSettings as they are now handled via API
  // and integrated into loadPrinterSettings and updatePrinterSettings above.

  Future<void> openDrawer() async {
    if (state.connectedPrinter == null) {
      ToastHelper.showError("No printer connected");
      return;
    }
    try {
      await _printingRepo.openDrawer(state.connectedPrinter!);
      ToastHelper.showSuccess("Drawer command sent");
    } catch (e) {
      log(e.toString());
      ToastHelper.showError("Failed to open drawer");
    }
  }

  Future<void> testPrint() async {
    if (state.connectedPrinter == null) {
      ToastHelper.showError("No printer connected");
      return;
    }
    try {
      await _printingRepo.testPrint(state.connectedPrinter!);
      ToastHelper.showSuccess("Test print sent");
    } catch (e) {
      log(e.toString());
      ToastHelper.showError("Failed to test print");
    }
  }

  Future<void> setPaperSize(PrinterPaperSize size) async {
    await _printingRepo.savePaperSize(size);
    emit(state.copyWith(showPaperSizeDialog: false, currentPaperSize: size));
  }

  Future<void> getPaperSize() async {
    final size = await _printingRepo.getPaperSize();
    emit(state.copyWith(currentPaperSize: size));
  }

  Future<void> getPrintingMode() async {
    final isServerPrinting = await _printingRepo
        .isPrintingFromServerSideOrNot();
    emit(state.copyWith(isServerPrinting: isServerPrinting));
    if (isServerPrinting) {
      fetchServerPrinters();

      final savedPrinter = await _printingRepo.getSelectedServerPrinter();
      if (savedPrinter != null) {
        emit(state.copyWith(selectedServerPrinter: savedPrinter));
      }

    }
  }

  Future<void> togglePrintingMode(bool value) async {
    await _printingRepo.settingPrintingToServerSide(isApiPrinter: value);
    emit(state.copyWith(isServerPrinting: value));
    if (value) {
      fetchServerPrinters();
    }
  }

  Future<void> fetchServerPrinters() async {
    emit(state.copyWith(isFetchingServerPrinters: true));
    final result = await _printingRepo.getServerPrinters(
      width: state.currentPaperSize?.widthInPixels,
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isFetchingServerPrinters: false,
            errorMessage: failure,
          ),
        );
        ToastHelper.showError(failure);
      },
      (printers) {
        emit(
          state.copyWith(
            isFetchingServerPrinters: false,
            serverPrinters: printers,
          ),
        );
      },
    );

  }

  Future<void> _tryAutoConnect() async {
    final lastPrinter = await _printingRepo.getLastConnectedPrinter();
    if (lastPrinter != null) {
      log("Auto-connecting to: ${lastPrinter.name}");
      connect(lastPrinter);
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (state.connectedPrinter != null &&
          state.status == PrintingStatus.connected) {
        _printingRepo.sendHeartbeat(state.connectedPrinter!);
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  Future<void> close() {
    _printerSubscription?.cancel();
    _statusSubscription?.cancel();
    _stopHeartbeat();
    return super.close();
  }
}