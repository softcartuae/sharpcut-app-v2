import 'package:dartz/dartz.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/domain/printing/model/printer_settings_model.dart';
import 'package:sharp_cut/domain/printing/model/printer_paper_size.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';

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

  Future<void> savePaperSize(Printer printer, PrinterPaperSize size);
  Future<PrinterPaperSize> getPaperSize(Printer printer);
  Future<bool> hasPaperSize(Printer printer);
}
