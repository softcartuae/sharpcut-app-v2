import 'package:flutter/material.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/presentation/printing/widgets/receipt_widget.dart';

class TestReceiptScreen extends StatelessWidget {
  const TestReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Shop Data
    final dummyShop = ShopModel(
      name: 'TAJ SHALEELA SALON',
      address: 'Abu Dhabi _ U.A.E',
      vatNo: '104426133500003',
     
    );

    // Dummy Cart Items
    final dummyCartItems = [
      CartItemModel(
        service: ServiceModel(
          name: 'Beard Shave',
          nameArabic: 'حلاقة اللحية',
          charge: 21.00,
        ),
        quantity: 1,
      ),
      CartItemModel(
        service: ServiceModel(
          name: 'Hair cut',
          nameArabic: 'قص الشعر',
          charge: 21.00,
        ),
        quantity: 1,
      ),
      CartItemModel(
        service: ServiceModel(
          name: 'Hair Oil Treatment',
          nameArabic: 'حمام زيت',
          charge: 42.00,
        ),
        quantity: 1,
      ),
      CartItemModel(
        service: ServiceModel(
          name: 'Face Cleaning',
          nameArabic: 'تنظيف الوجه',
          charge: 21.00,
        ),
        quantity: 1,
      ),
    ];

    // Dummy Request Data
    final dummyRequest = SettlePaymentRequestModel(
      customerName: 'John Doe',
      finalTotalbefore: 200,
      transactionId: 36979,
      subTotalValue: 95.24, // Subtotal
      taxTotal: 4.76, // VAT
      discount: 0.0,
      finalTotal: 100.00, // Net Amount
      subTotalList: [95.24], // Just for display logic if needed
      mode: ['Cash'],
      amount: [100.00],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Receipt Widget'),
        backgroundColor: Colors.grey[200],
      ),
      backgroundColor:
          Colors.grey[300], // Darker background to see the receipt clearly
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: ReceiptWidget(
            chairId: 1,
            invoiceDate: "2024-01-01",
            balanceAmount: 100,
            shopData: dummyShop,
            request: dummyRequest,
            cartItems: dummyCartItems,
            bookingTime: "12:00 PM",
            staffName: "ABBAS",
            invoiceNumber: "INV-00001",
          ),
        ),
      ),
    );
  }
}
