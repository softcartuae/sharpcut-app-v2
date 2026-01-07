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

  PrintingState({
    this.status = PrintingStatus.initial,
    this.printers = const [],
    this.connectedPrinter,
    this.errorMessage,
    this.scanningType,
    this.settings,
    this.isLoading = false,
  });

  PrintingState copyWith({
    PrintingStatus? status,
    List<Printer>? printers,
    Printer? connectedPrinter,
    String? errorMessage,
    ConnectionType? scanningType,
    PrinterSettingsModel? settings,
    bool? isLoading,
  }) {
    return PrintingState(
      status: status ?? this.status,
      printers: printers ?? this.printers,
      connectedPrinter: connectedPrinter ?? this.connectedPrinter,
      errorMessage: errorMessage ?? this.errorMessage,
      scanningType: scanningType ?? this.scanningType,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
