import 'dart:ffi';

import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WindowsPrinterPlatform {

  /// Lists all local printers using EnumPrinters.
  List<String> getPrinters() {
    final printers = <String>[];
    // Flags: PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS
    const flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;

    // First call to get needed buffer size
    final pCbNeeded = calloc<DWORD>();
    final pPcReturned = calloc<DWORD>();

    EnumPrinters(flags, nullptr, 2, nullptr, 0, pCbNeeded, pPcReturned);

    final cbNeeded = pCbNeeded.value;
    final pPrinterEnum = calloc<Uint8>(cbNeeded);

    // Second call to get the data
    if (EnumPrinters(
          flags,
          nullptr,
          2,
          pPrinterEnum,
          cbNeeded,
          pCbNeeded,
          pPcReturned,
        ) !=
        0) {
      final count = pPcReturned.value;
      final printerInfoPtr = pPrinterEnum.cast<PRINTER_INFO_2>();

      for (int i = 0; i < count; i++) {
        final info = printerInfoPtr[i];
        if (info.pPrinterName != nullptr) {
          printers.add(info.pPrinterName.toDartString());
        }
      }
    }

    free(pCbNeeded);
    free(pPcReturned);
    free(pPrinterEnum);

    return printers;
  }

  /// Sends raw bytes to the Windows printer spooler.
  Future<bool> print(String printerName, Uint8List data) async {
    return Future(() {
      final pPrinterName = printerName.toNativeUtf16();
      final phPrinter = calloc<HANDLE>();
      final pDocInfo = calloc<DOC_INFO_1>();
      final pBytesWritten = calloc<DWORD>();

      try {
        // 1. Open Printer
        if (OpenPrinter(pPrinterName, phPrinter, nullptr) == 0) return false;

        // 2. Start Document
        pDocInfo.ref.pDocName = 'SharpCut Receipt'.toNativeUtf16();
        pDocInfo.ref.pOutputFile = nullptr;
        pDocInfo.ref.pDatatype = 'RAW'.toNativeUtf16();

        if (StartDocPrinter(phPrinter.value, 1, pDocInfo) == 0) {
          ClosePrinter(phPrinter.value);
          return false;
        }

        // 3. Start Page
        if (StartPagePrinter(phPrinter.value) == 0) {
          EndDocPrinter(phPrinter.value);
          ClosePrinter(phPrinter.value);
          return false;
        }

        // 4. Write Data
        final pData = calloc<Uint8>(data.length);
        for (var i = 0; i < data.length; i++) {
          pData[i] = data[i];
        }

        final result = WritePrinter(
          phPrinter.value,
          pData,
          data.length,
          pBytesWritten,
        );

        free(pData);

        // 5. End Page & Document
        EndPagePrinter(phPrinter.value);
        EndDocPrinter(phPrinter.value);
        ClosePrinter(phPrinter.value);

        return result != 0;
      } finally {
        free(pPrinterName);
        free(phPrinter);
        free(pDocInfo);
        free(pBytesWritten);
      }
    });
  }
}

