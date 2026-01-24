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
  final PrinterPaperSize? currentPaperSize;
  final List<ServerPrinter> serverPrinters;
  final bool isFetchingServerPrinters;
  final ServerPrinter? selectedServerPrinter;

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
    this.currentPaperSize,
    this.serverPrinters = const [],
    this.isFetchingServerPrinters = false,
    this.selectedServerPrinter,
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
    PrinterPaperSize? currentPaperSize,
    List<ServerPrinter>? serverPrinters,
    bool? isFetchingServerPrinters,
    ServerPrinter? selectedServerPrinter,
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
      currentPaperSize: currentPaperSize ?? this.currentPaperSize,
      serverPrinters: serverPrinters ?? this.serverPrinters,
      isFetchingServerPrinters:
          isFetchingServerPrinters ?? this.isFetchingServerPrinters,
      selectedServerPrinter:
          selectedServerPrinter ?? this.selectedServerPrinter,
    );
  }
}
