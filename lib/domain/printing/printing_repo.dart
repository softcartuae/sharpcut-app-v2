import 'package:dartz/dartz.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/domain/printing/model/printer_settings_model.dart';
import 'package:sharp_cut/domain/printing/model/printer_paper_size.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';
import 'package:sharp_cut/domain/printing/model/server_printer.dart';

abstract class PrintingRepo {
  Stream<List<Printer>> get printersStream;
  Stream<Map<String, dynamic>> get statusStream;
  Future<void> startScan({List<ConnectionType>? connectionTypes});
  Future<void> stopScan();
  Future<bool> connect(Printer printer);
  Future<void> disconnect(Printer printer);
  Future<void> printInvoice({
    required Printer printer,
    required SettlePaymentRequestModel request,
    required ShopModel shopData,
    required double balanceAmount,
    required List<CartItemModel> cartItems,
    required String? staffName,
    required String? invoiceNumber,
    required String? bookingTime,
    required String? invoiceDate,
    required int? chairId,
    String? endTime,
    int copies = 1,
    bool openDrawer = false,
  });

  Future<void> printQuickReport({
    required Printer printer,
    required QuickReportModel report,
    int copies = 1,
    bool openDrawer = false,
  });

  Future<void> printCloseRegisterReport({
    required Printer printer,
    required CloseRegisterReportModel report,
    required ShopModel shop,
    int copies = 1,
    bool openDrawer = false,
  });

  Future<void> openDrawer(Printer printer);
  Future<void> testPrint(Printer printer);

  Future<Either<String, PrinterSettingsModel>> getPrinterSettings();
  Future<Either<String, void>> updatePrinterSettings(
    PrinterSettingsModel model,
  );

  Future<void> savePaperSize(PrinterPaperSize size);
  Future<PrinterPaperSize> getPaperSize();
  Future<bool> hasPaperSize();

  Future<void> settingPrintingToServerSide({required bool isApiPrinter});
  Future<bool> isPrintingFromServerSideOrNot();

  Future<Either<String, List<ServerPrinter>>> getServerPrinters({int? width});

  Future<Either<String, void>> printServerPrinter({
    required int transactionId,
    required String printerName,
    required int size,
  });

  Future<void> saveSelectedServerPrinter(ServerPrinter printer);
  Future<ServerPrinter?> getSelectedServerPrinter();

  Future<Either<String, void>> printQuickReportServer({
    required String dateRange,
    required int? userId,
    required String printerName,
    required int size,
  });

  Future<Either<String, void>> printCashRegisterReportServer({
    required int cashRegisterId,
    required String printerName,
    required int size,
  });

  Future<void> saveLastConnectedPrinter(Printer printer);
  Future<Printer?> getLastConnectedPrinter();
  Future<void> clearLastConnectedPrinter();
  Future<void> sendHeartbeat(Printer printer);
  Future<int?> checkPrinterStatus(Printer printer);

  
}
