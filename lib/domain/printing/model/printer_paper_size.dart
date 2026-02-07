import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

enum PrinterPaperSize {
  mm58,
  mm80,
  inch4;

  int get widthInPixels {
    switch (this) {
      case PrinterPaperSize.mm58:
        return 384;
      case PrinterPaperSize.mm80:
        return 576;
      case PrinterPaperSize.inch4:
        return 832;
    }
  }

  PaperSize get generatorPaperSize {
    switch (this) {
      case PrinterPaperSize.mm58:
        return PaperSize.mm58;
      case PrinterPaperSize.mm80:
      case PrinterPaperSize.inch4:
        return PaperSize.mm80;
    }
  }

  String get label {
    switch (this) {
      case PrinterPaperSize.mm58:
        return "58mm (2 inch)";
      case PrinterPaperSize.mm80:
        return "80mm (3 inch)";
      case PrinterPaperSize.inch4:
        return "104mm (4 inch)";
    }
  }
}
