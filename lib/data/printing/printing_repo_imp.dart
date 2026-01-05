import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/printing/printing_repo.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

import '../../presentation/printing/widgets/receipt_widget.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/presentation/quick_report/widgets/quick_report_print_widget.dart';

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
    await _printer.stopScan();
  }

  @override
  Future<bool> connect(Printer printer) async {
    return await _printer.connect(printer);
  }

  @override
  Future<void> disconnect(Printer printer) async {
    await _printer.disconnect(printer);
  }

  @override
  Future<void> printInvoice({
    required Printer printer,
    required SettlePaymentRequestModel request,
    required ShopModel shopData,
    required List<CartItemModel> cartItems,
    required double balanceAmount,
    required String? staffName,
    required String? invoiceNumber,
    required String? bookingTime,
     int copies = 1,
  }) async {
    
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Create the receipt widget
    final receiptWidget = MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: ThemeData(
            useMaterial3: false,
            scaffoldBackgroundColor: Colors.white,
          ),
          child: Material(
            color: Colors.white,
            child: ReceiptWidget(
              balanceAmount: balanceAmount,
              staffName: staffName,
              invoiceNumber: invoiceNumber,
              bookingTime: bookingTime,
              shopData: shopData,
              request: request,
              cartItems: cartItems,
            ),
          ),
        ),
      ),
    );
    // Calculate estimated height
    // Base height (Header + Footer) ~ 600
    // Per item ~ 60 (allowing for wrapping text)
    double estimatedHeight = 600 + (cartItems.length * 60.0);

    // Capture the widget as an image
    final ScreenshotController screenshotController = ScreenshotController();
    final Uint8List capturedImage = await screenshotController
        .captureFromWidget(
          receiptWidget,
          delay: const Duration(milliseconds: 100),
          pixelRatio: 1.0, // Reduced to avoid buffer overflow
          targetSize: Size(370, estimatedHeight), // Ensure height is sufficient
        );

    // Decode the image for the printer
    final img.Image? image = img.decodePng(capturedImage);

    if (image != null) {
      // Resize to 384 (standard 58mm width, multiple of 8)
      final img.Image resizedImage = img.copyResize(image, width: 384);

      bytes.addAll(generator.image(resizedImage));
    }

    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    await _printer.printData(printer, bytes);
    // Loop 'copies' times
// for (int i = 0; i < copies; i++) {
//   await _printer.printData(printer, bytes);
  
//   // Optional: Add a small delay between copies to prevent printer buffer overflow
//   if (i < copies - 1) {
//     await Future.delayed(const Duration(milliseconds: 500)); 
//   }
// }
  }

  @override
  Future<void> printQuickReport({
    required Printer printer,
    required QuickReportModel report,
    int copies = 1,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Create the widget
    final widget = MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: ThemeData(
            useMaterial3: false,
            scaffoldBackgroundColor: Colors.white,
          ),
          child: Material(
            color: Colors.white,
            child: QuickReportPrintWidget(report: report),
          ),
        ),
      ),
    );

    // Calculate estimated height
    // Base height ~ 600 + items
    double estimatedHeight = 1000 + (report.salesmanWiseDetails.length * 40.0);

    // Capture the widget as an image
    final ScreenshotController screenshotController = ScreenshotController();
    final Uint8List capturedImage = await screenshotController.captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 100),
      pixelRatio: 1.0,
      targetSize: Size(370, estimatedHeight),
    );

    // Decode the image for the printer
    final img.Image? image = img.decodePng(capturedImage);

    if (image != null) {
      // Resize to 384 (standard 58mm width)
      final img.Image resizedImage = img.copyResize(image, width: 384);
      bytes.addAll(generator.image(resizedImage));
    }

    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    await _printer.printData(printer, bytes);
    // Loop 'copies' times
// for (int i = 0; i < copies; i++) {
//   await _printer.printData(printer, bytes);
  
//   // Optional: Add a small delay between copies to prevent printer buffer overflow
//   if (i < copies - 1) {
//     await Future.delayed(const Duration(milliseconds: 500)); 
//   }
// }
  }
}
