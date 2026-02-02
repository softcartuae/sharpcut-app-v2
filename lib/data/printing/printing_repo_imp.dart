import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:sharp_cut/domain/printing/model/printer_paper_size.dart';
import 'package:sharp_cut/domain/printing/model/server_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sharp_cut/data/printing/service/printing_service.dart';
import 'package:sharp_cut/data/printing/native/usb_printer_platform.dart';
import 'package:sharp_cut/data/printing/native/bluetooth_printer_platform.dart';
import 'package:sharp_cut/data/printing/native/network_printer_platform.dart';

import 'package:sharp_cut/presentation/printing/widgets/receipt_widget.dart';
import 'package:sharp_cut/presentation/quick_report/widgets/quick_report_print_widget.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';
import 'package:sharp_cut/presentation/cash_registory/widgets/close_register_print_widget.dart';

class PrintingRepoImp implements PrintingRepo {
  final PrintingService _printingService;

  final UsbPrinterPlatform _usbPlatform = UsbPrinterPlatform();
  final BluetoothPrinterPlatform _bluetoothPlatform =
      BluetoothPrinterPlatform();
  final NetworkPrinterPlatform _networkPlatform = NetworkPrinterPlatform();

  // Stream controller to merge/manage printers from both sources
  final StreamController<List<Printer>> _printersController =
      StreamController<List<Printer>>.broadcast();

  static const EventChannel _eventChannel = EventChannel(
    'com.example.sharp_cut/printer_status',
  );

  PrintingRepoImp(this._printingService);

  @override
  Stream<List<Printer>> get printersStream => _printersController.stream;

  @override
  Stream<Map<String, dynamic>> get statusStream => _eventChannel
      .receiveBroadcastStream()
      .map((event) => Map<String, dynamic>.from(event));

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
    required String? invoiceDate,
    required int? chairId,
    String? endTime,
    int copies = 1,
    bool openDrawer = false,
  }) async {
    try {
      final profile = await CapabilityProfile.load();
      final paperSize = await getPaperSize();
      final generator = Generator(paperSize.generatorPaperSize, profile);
      // Open drawer immediately if requested
      if (openDrawer) {
        try {
          final drawerBytes = generator.drawer();
          await _printBytes(printer, Uint8List.fromList(drawerBytes));
        } catch (e) {
          log("Error opening drawer immediately: $e");
        }
      }

      List<int> bytes = [];

      final double targetWidth = paperSize.widthInPixels.toDouble();

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
                chairId: chairId,
                balanceAmount: balanceAmount,
                staffName: staffName,
                invoiceNumber: invoiceNumber,
                bookingTime: bookingTime,
                shopData: shopData,
                request: request,
                cartItems: cartItems,
                width: targetWidth,
                invoiceDate: invoiceDate,
                endTime: endTime,
              ),
            ),
          ),
        ),
      );

      double estimatedHeight = 1350 + (cartItems.length * 100.0);

      final ScreenshotController screenshotController = ScreenshotController();
      final Uint8List capturedImage = await screenshotController
          .captureFromWidget(
            receiptWidget,
            delay: const Duration(milliseconds: 100),
            pixelRatio:
                1.0, // Keep resolution low (1.0 is standard screen density)
            targetSize: Size(targetWidth, estimatedHeight),
          );

      final img.Image? image = img.decodePng(capturedImage);

      if (image != null) {
        // Resize to paper width using nearest neighbor interpolation (fastest)
        final img.Image resizedImage = img.copyResize(
          image,
          width: paperSize.widthInPixels,
          interpolation: img.Interpolation.nearest,
        );

        // Convert to grayscale to reduce data size and processing time for the printer
        final img.Image grayscaleImage = img.grayscale(resizedImage);

        bytes.addAll(generator.image(grayscaleImage));
      }

      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      for (int i = 0; i < copies; i++) {
        await _printBytes(printer, Uint8List.fromList(bytes));

        if (i < copies - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      log(e.toString());
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
    final paperSize = await getPaperSize();
    final generator = Generator(paperSize.generatorPaperSize, profile);
    List<int> bytes = [];
    log("called in quick report");

    // Open drawer immediately if requested
    if (openDrawer) {
      try {
        final drawerBytes = generator.drawer();
        await _printBytes(printer, Uint8List.fromList(drawerBytes));
      } catch (e) {
        log("Error opening drawer immediately: $e");
      }
    }

    // Create the widget
    final double targetWidth = paperSize.widthInPixels.toDouble();

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
            child: QuickReportPrintWidget(report: report, width: targetWidth),
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

    log("called in iamge procees $estimatedHeight width: $targetWidth");
    // Capture the widget as an image
    final ScreenshotController screenshotController = ScreenshotController();
    final Uint8List capturedImage = await screenshotController
        .captureFromWidget(
          widget,
          delay: const Duration(milliseconds: 100),
          pixelRatio: 1.0, // Keep resolution low
          targetSize: Size(targetWidth, estimatedHeight),
        );

    // Decode the image for the printer
    final img.Image? image = img.decodePng(capturedImage);
    log("called in iamge procees $image");

    if (image != null) {
      // Resize to paper width using nearest neighbor interpolation (fastest)
      final img.Image resizedImage = img.copyResize(
        image,
        width: paperSize.widthInPixels,
        interpolation: img.Interpolation.nearest,
      );

      // Convert to grayscale
      final img.Image grayscaleImage = img.grayscale(resizedImage);

      bytes.addAll(generator.image(grayscaleImage));
    }

    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    for (int i = 0; i < copies; i++) {
      log("called in loop");
      try {
        await _printBytes(printer, Uint8List.fromList(bytes));
      } catch (e) {
        log(e.toString());
      }
      log("called in loop end");
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
  Future<void> printCloseRegisterReport({
    required Printer printer,
    required CloseRegisterReportModel report,
    required ShopModel shop,
    int copies = 1,
    bool openDrawer = false,
  }) async {
    final profile = await CapabilityProfile.load();
    final paperSize = await getPaperSize();
    final generator = Generator(paperSize.generatorPaperSize, profile);
    List<int> bytes = [];

    // Open drawer immediately if requested
    if (openDrawer) {
      try {
        final drawerBytes = generator.drawer();
        await _printBytes(printer, Uint8List.fromList(drawerBytes));
      } catch (e) {
        log("Error opening drawer immediately: $e");
      }
    }

    // Create the widget
    final double targetWidth = paperSize.widthInPixels.toDouble();

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
            child: CloseRegisterPrintWidget(
              report: report,
              shop: shop,
              width: targetWidth,
            ),
          ),
        ),
      ),
    );

    // Calculate estimated height
    // Base height ~ 1000 + items
    double estimatedHeight = 1500;
    if (report.transactions != null) {
      estimatedHeight +=
          (report.transactions!.salesmanWiseDetails.length * 40.0) +
          (report.transactions!.invoiceDetails.length * 40.0);
    }

    // Capture the widget as an image
    final ScreenshotController screenshotController = ScreenshotController();
    final Uint8List capturedImage = await screenshotController
        .captureFromWidget(
          widget,
          delay: const Duration(milliseconds: 100),
          pixelRatio: 1.0, // Keep resolution low
          targetSize: Size(targetWidth, estimatedHeight),
        );

    // Decode the image for the printer
    final img.Image? image = img.decodePng(capturedImage);

    if (image != null) {
      // Resize to paper width using nearest neighbor interpolation (fastest)
      final img.Image resizedImage = img.copyResize(
        image,
        width: paperSize.widthInPixels,
        interpolation: img.Interpolation.nearest,
      );

      // Convert to grayscale
      final img.Image grayscaleImage = img.grayscale(resizedImage);

      bytes.addAll(generator.image(grayscaleImage));
    }

    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    for (int i = 0; i < copies; i++) {
      try {
        await _printBytes(printer, Uint8List.fromList(bytes));
      } catch (e) {
        log(e.toString());
      }
      if (i < copies - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
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

  @override
  Future<void> testPrint(Printer printer) async {
    final profile = await CapabilityProfile.load();
    final paperSize = await getPaperSize();
    final generator = Generator(paperSize.generatorPaperSize, profile);
    List<int> bytes = [];

    bytes.addAll(
      generator.text(
        "printer connected successfull",
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    await _printBytes(printer, Uint8List.fromList(bytes));
  }

  @override
  Future<void> savePaperSize(PrinterPaperSize size) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "printer_size";
    await prefs.setString(key, size.name);
  }

  @override
  Future<PrinterPaperSize> getPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "printer_size";
    final sizeName = prefs.getString(key);
    if (sizeName != null) {
      return PrinterPaperSize.values.firstWhere(
        (e) => e.name == sizeName,
        orElse: () => PrinterPaperSize.mm58,
      );
    }
    return PrinterPaperSize.mm58; // Default
  }

  @override
  Future<bool> hasPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "printer_size";
    return prefs.containsKey(key);
  }

  @override
  Future<void> settingPrintingToServerSide({required bool isApiPrinter}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_server_printing", isApiPrinter);
  }

  @override
  Future<bool> isPrintingFromServerSideOrNot() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_server_printing") ?? false;
  }

  @override
  Future<Either<String, List<ServerPrinter>>> getServerPrinters({
    int? width,
  }) async {
    try {
      final response = await _printingService.getServerPrinters();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> printers = response.data['printers'];
        final serverPrinters = printers
            .map((name) => ServerPrinter(name: name.toString(), width: width))
            .toList();
        return Right(serverPrinters);
      } else {
        return Left(response.data['message'] ?? "Failed to fetch printers");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> printServerPrinter({
    required int transactionId,
    required String printerName,
    required int size,
  }) async {
    try {
      final response = await _printingService.printInvoice(
        transactionId: transactionId,
        printerName: printerName,
        size: size,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      } else {
        return Left(response.data['message'] ?? "Failed to print invoice");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<void> saveSelectedServerPrinter(ServerPrinter printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_server_printer', printer.name ?? '');
  }

  @override
  Future<ServerPrinter?> getSelectedServerPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('selected_server_printer');
    if (name != null && name.isNotEmpty) {
      return ServerPrinter(name: name);
    }
    return null;
  }

  @override
  Future<Either<String, void>> printQuickReportServer({
    required String dateRange,
    required int? userId,
    required String printerName,
    required int size,
  }) async {
    try {
      final response = await _printingService.printQuickReport(
        dateRange: dateRange,
        userId: userId,
        printerName: printerName,
        size: size,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      } else {
        return Left(response.data['message'] ?? "Failed to print quick report");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> printCashRegisterReportServer({
    required int cashRegisterId,
    required String printerName,
    required int size,
  }) async {
    try {
      final response = await _printingService.printCashRegisterReport(
        cashRegisterId: cashRegisterId,
        printerName: printerName,
        size: size,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      } else {
        return Left(
          response.data['message'] ?? "Failed to print cash register report",
        );
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<void> saveLastConnectedPrinter(Printer printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_printer_name', printer.name ?? '');
    await prefs.setString('last_printer_vendor', printer.vendorId ?? '');
    await prefs.setString('last_printer_product', printer.productId ?? '');
    await prefs.setString('last_printer_address', printer.address ?? '');
    await prefs.setInt('last_printer_type', printer.connectionType?.index ?? 0);
  }

  @override
  Future<Printer?> getLastConnectedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('last_printer_type')) return null;

    final typeIndex = prefs.getInt('last_printer_type');
    final type = ConnectionType.values[typeIndex!];
    final name = prefs.getString('last_printer_name');
    final vendor = prefs.getString('last_printer_vendor');
    final product = prefs.getString('last_printer_product');
    final address = prefs.getString('last_printer_address');

    return Printer(
      name: name,
      vendorId: vendor,
      productId: product,
      address: address,
      connectionType: type,
    );
  }

  @override
  Future<void> clearLastConnectedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_printer_name');
    await prefs.remove('last_printer_vendor');
    await prefs.remove('last_printer_product');
    await prefs.remove('last_printer_address');
    await prefs.remove('last_printer_type');
  }

  @override
  Future<void> sendHeartbeat(Printer printer) async {
    // DLE EOT 1 : Real-time status transmission
    // Bytes: 16 (DLE), 4 (EOT), 1 (Recoverable error status) - or just 1 for general status
    // Common ESC/POS keep-alive
    final bytes = Uint8List.fromList([16, 4, 1]);
    await _printBytes(printer, bytes);
  }
}
