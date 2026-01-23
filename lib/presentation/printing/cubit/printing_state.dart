part of 'printing_cubit.dart';

enum PrintingStatus {
  initial,
  scanning,
  connecting,
  disconnecting,
  connected,
  printing,
  printed,
  error,
}

class PrintingState {
  final PrintingStatus status;
  final List<Printer> printers;
  final Printer? connectedPrinter;
  final String? errorMessage;
  final ConnectionType? scanningType;
  final PrinterSettingsModel? settings;
  final bool isLoading;
  final bool showPaperSizeDialog;
  final bool isServerPrinting;

  PrintingState({
    this.status = PrintingStatus.initial,
    this.printers = const [],
    this.connectedPrinter,
    this.errorMessage,
    this.scanningType,
    this.settings,
    this.isLoading = false,
    this.showPaperSizeDialog = false,
    this.isServerPrinting = false,
  });

  PrintingState copyWith({
    PrintingStatus? status,
    List<Printer>? printers,
    Printer? connectedPrinter,
    String? errorMessage,
    ConnectionType? scanningType,
    PrinterSettingsModel? settings,
    bool? isLoading,
    bool? showPaperSizeDialog,
    bool clearConnectedPrinter = false,
    bool? isServerPrinting,
  }) {
    return PrintingState(
      status: status ?? this.status,
      printers: printers ?? this.printers,
      connectedPrinter: clearConnectedPrinter
          ? null
          : (connectedPrinter ?? this.connectedPrinter),
      errorMessage: errorMessage ?? this.errorMessage,
      scanningType: scanningType ?? this.scanningType,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      showPaperSizeDialog: showPaperSizeDialog ?? this.showPaperSizeDialog,
      isServerPrinting: isServerPrinting ?? this.isServerPrinting,
    );
  }
}
