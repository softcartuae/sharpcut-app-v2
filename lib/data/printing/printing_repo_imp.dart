import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;

import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/printing/printing_repo.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/domain/printing/model/printer_settings_model.dart';

import 'package:sharp_cut/data/printing/service/printing_service.dart';
import 'package:sharp_cut/data/printing/native/usb_printer_platform.dart';
import 'package:sharp_cut/data/printing/native/bluetooth_printer_platform.dart';
import 'package:sharp_cut/data/printing/native/network_printer_platform.dart';

import '../../presentation/printing/widgets/receipt_widget.dart';
import 'package:sharp_cut/presentation/quick_report/widgets/quick_report_print_widget.dart';

class PrintingRepoImp implements PrintingRepo {
  final PrintingService _printingService;

  final UsbPrinterPlatform _usbPlatform = UsbPrinterPlatform();
  final BluetoothPrinterPlatform _bluetoothPlatform =
      BluetoothPrinterPlatform();
  final NetworkPrinterPlatform _networkPlatform = NetworkPrinterPlatform();

  // Stream controller to merge/manage printers from both sources
  final StreamController<List<Printer>> _printersController =
      StreamController<List<Printer>>.broadcast();

  PrintingRepoImp(this._printingService);

  @override
  Stream<List<Printer>> get printersStream => _printersController.stream;

  @override
  Future<void> startScan({List<ConnectionType>? connectionTypes}) async {
    // Clear previous results
    _printersController.add([]);

    final types =
        connectionTypes ??
        [ConnectionType.USB, ConnectionType.BLE, ConnectionType.NETWORK];
    List<Printer> allPrinters = [];

    // Native USB Scan
    if (types.contains(ConnectionType.USB)) {
      try {
        final devices = await _usbPlatform.getUsbDevices();
        final printers = devices.map((d) {
          return Printer(
            name: d['name'],
            vendorId: d['vendorId'].toString(),
            productId: d['productId'].toString(),
            connectionType: ConnectionType.USB,
          );
        }).toList();
        allPrinters.addAll(printers);
      } catch (e) {
        log("Native USB Scan Error: $e");
      }
    }

    // Native Bluetooth Scan
    if (types.contains(ConnectionType.BLE)) {
      try {
        final devices = await _bluetoothPlatform.getBluetoothDevices();
        final printers = devices.map((d) {
          return Printer(
            name: d['name'],
            address: d['address'],
            connectionType: ConnectionType.BLE,
          );
        }).toList();
        allPrinters.addAll(printers);
      } catch (e) {
        log("Native Bluetooth Scan Error: $e");
      }
    }

    // Native Network Scan (or just manual entry support)
    if (types.contains(ConnectionType.NETWORK)) {
      // For network, we might not scan automatically or we might support it later.
      // If we had a scan method, we'd call it here.
      // For now, we can rely on user adding printer manually or simple subnet scan if implemented.
      try {
        final devices = await _networkPlatform.scan(
          null,
        ); // null for default subnet
        final printers = devices.map((d) {
          return Printer(
            name: d['name'] ?? "Network Printer",
            address: d['ipAddress'], // Assuming map has ipAddress
            connectionType: ConnectionType.NETWORK,
          );
        }).toList();
        allPrinters.addAll(printers);
      } catch (e) {
        log("Native Network Scan Error: $e");
      }
    }

    _printersController.add(allPrinters);
  }

  @override
  Future<void> stopScan() async {
    // Native scans are usually one-shot or handled differently.
    // We can just clear the stream or do nothing.
  }

  @override
  Future<bool> connect(Printer printer) async {
    if (printer.connectionType == ConnectionType.USB) {
      try {
        final int vendorId = int.parse(printer.vendorId!);
        final int productId = int.parse(printer.productId!);
        return await _usbPlatform.connect(vendorId, productId);
      } catch (e) {
        log("Native USB Connect Error: $e");
        return false;
      }
    } else if (printer.connectionType == ConnectionType.BLE) {
      try {
        return await _bluetoothPlatform.connect(printer.address!);
      } catch (e) {
        log("Native Bluetooth Connect Error: $e");
        return false;
      }
    } else if (printer.connectionType == ConnectionType.NETWORK) {
      try {
        // Assuming address is "IP:Port" or just "IP"
        // If just IP, default port 9100
        String ip = printer.address!;
        int port = 9100;
        if (ip.contains(':')) {
          final parts = ip.split(':');
          ip = parts[0];
          port = int.tryParse(parts[1]) ?? 9100;
        }
        return await _networkPlatform.connect(ip, port);
      } catch (e) {
        log("Native Network Connect Error: $e");
        return false;
      }
    }
    return false;
  }

  @override
  Future<void> disconnect(Printer printer) async {
    if (printer.connectionType == ConnectionType.USB) {
      await _usbPlatform.disconnect();
    } else if (printer.connectionType == ConnectionType.BLE) {
      await _bluetoothPlatform.disconnect();
    } else if (printer.connectionType == ConnectionType.NETWORK) {
      await _networkPlatform.disconnect();
    }
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
    bool openDrawer = false,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    if (openDrawer) {
      bytes.addAll(generator.drawer());
    }

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
    // Base height (Header + Footer) ~ 800
    // Per item ~ 70 (allowing for wrapping text)
    double estimatedHeight = 800 + (cartItems.length * 70.0);

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

    // Loop 'copies' times
    for (int i = 0; i < copies; i++) {
      await _printBytes(printer, Uint8List.fromList(bytes));

      // Optional: Add a small delay between copies to prevent printer buffer overflow
      if (i < copies - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  @override
  Future<void> printQuickReport({
    required Printer printer,
    required QuickReportModel report,
    int copies = 1,
    bool openDrawer = false,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    try {
      if (openDrawer) {
        bytes.addAll(generator.drawer());
      }
    } catch (e) {
      log(e.toString());
    }

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
    // Base height ~ 1000 + items
    double estimatedHeight =
        1000 +
        (report.salesmanWiseDetails.length * 40.0) +
        (report.invoiceDetails.length * 40.0);

    // Capture the widget as an image
    final ScreenshotController screenshotController = ScreenshotController();
    final Uint8List capturedImage = await screenshotController
        .captureFromWidget(
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

    for (int i = 0; i < copies; i++) {
      await _printBytes(printer, Uint8List.fromList(bytes));

      if (i < copies - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<void> _printBytes(Printer printer, Uint8List bytes) async {
    if (printer.connectionType == ConnectionType.USB) {
      await _usbPlatform.print(bytes);
    } else if (printer.connectionType == ConnectionType.BLE) {
      await _bluetoothPlatform.print(bytes);
    } else if (printer.connectionType == ConnectionType.NETWORK) {
      await _networkPlatform.print(bytes);
    }
  }

  @override
  Future<Either<String, PrinterSettingsModel>> getPrinterSettings() async {
    try {
      final response = await _printingService.getPrinterSettings();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(PrinterSettingsModel.fromJson(response.data['data']));
      } else {
        return Left(response.data['message']);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updatePrinterSettings(
    PrinterSettingsModel model,
  ) async {
    try {
      final response = await _printingService.updatePrinterSettings(model);
      if (response.statusCode != 200 && response.statusCode != 201) {
        return Left(response.data['message']);
      }
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? "Failed To Update");
    } catch (e) {
      return Left("Failed To Update");
    }
  }

  @override
  Future<void> openDrawer(Printer printer) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    bytes.addAll(generator.drawer());

    await _printBytes(printer, Uint8List.fromList(bytes));
  }
}
