import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';

abstract class PrintingRepo {
  Stream<List<Printer>> get printersStream;
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
  });

  Future<void> printQuickReport({
    required Printer printer,
    required QuickReportModel report,
  });
}
