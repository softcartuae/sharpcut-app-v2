import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/domain/auth/models/user_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';

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
    required List<CartItemModel> cartItems,
  });
}
