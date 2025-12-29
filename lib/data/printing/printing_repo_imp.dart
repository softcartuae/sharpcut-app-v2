import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/domain/auth/models/user_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
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

  @override
  Future<void> printInvoice({
    required Printer printer,
    required SettlePaymentRequestModel request,
    required ShopModel shopData,
    required List<CartItemModel> cartItems,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes.addAll(
      generator.text(
        shopData.name ?? 'Shop Name',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      ),
    );

    if (shopData.address != null) {
      bytes.addAll(
        generator.text(
          shopData.address!,
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }
    if (shopData.vatNo != null) {
      bytes.addAll(
        generator.text(
          'TRN: ${shopData.vatNo}',
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }

    bytes.addAll(
      generator.text(
        'TAX INVOICE',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );

    bytes.addAll(generator.hr());

    // Invoice Details
    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'Date: ${request.transactionId}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Time: ',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'Invoice No: ${request.transactionId}',
          width: 12,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]),
    );

    bytes.addAll(generator.hr());

    // Items Header
    bytes.addAll(
      generator.row([
        PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
          text: 'Qty',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.center),
        ),
        PosColumn(
          text: 'Price',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
        PosColumn(
          text: 'Total',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(generator.hr());

    // Items
    for (var item in cartItems) {
      double price = double.tryParse(item.service.price ?? '0') ?? 0.0;
      double total = price * item.quantity;

      // English Name
      bytes.addAll(
        generator.row([
          PosColumn(text: item.service.name ?? '', width: 6),
          PosColumn(
            text: item.quantity.toString(),
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: price.toStringAsFixed(2),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: total.toStringAsFixed(2),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );

      // Arabic Name (if available)
      if (item.service.nameArabic != null &&
          item.service.nameArabic!.isNotEmpty) {
        bytes.addAll(
          generator.text(
            item.service.nameArabic!,
            styles: const PosStyles(align: PosAlign.right, codeTable: 'CP864'),
          ),
        );
      }
    }

    bytes.addAll(generator.hr());

    // Totals
    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'Sub Total',
          width: 8,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: (request.grandTotal ?? 0).toStringAsFixed(2),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'VAT Amount',
          width: 8,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: (request.taxTotal ?? 0).toStringAsFixed(2),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    if ((request.discount ?? 0) > 0) {
      bytes.addAll(
        generator.row([
          PosColumn(
            text: 'Discount',
            width: 8,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (request.discount ?? 0).toStringAsFixed(2),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }

    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'Net Amount',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: (request.finalTotal ?? 0).toStringAsFixed(2),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]),
    );

    bytes.addAll(generator.hr());

    // Payment Mode
    if (request.mode != null && request.mode!.isNotEmpty) {
      for (int i = 0; i < request.mode!.length; i++) {
        bytes.addAll(
          generator.row([
            PosColumn(
              text: request.mode![i],
              width: 8,
              styles: const PosStyles(align: PosAlign.right),
            ),
            PosColumn(
              text: (request.amount?[i] ?? 0).toStringAsFixed(2),
              width: 4,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]),
        );
      }
    }

    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    await _printer.printData(printer, bytes);
  }
}
