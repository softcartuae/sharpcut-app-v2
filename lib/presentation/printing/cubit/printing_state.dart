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

  PrintingState({
    this.status = PrintingStatus.initial,
    this.printers = const [],
    this.connectedPrinter,
    this.errorMessage,
    this.scanningType,
  });

  PrintingState copyWith({
    PrintingStatus? status,
    List<Printer>? printers,
    Printer? connectedPrinter,
    String? errorMessage,
    ConnectionType? scanningType,
  }) {
    return PrintingState(
      status: status ?? this.status,
      printers: printers ?? this.printers,
      connectedPrinter: connectedPrinter ?? this.connectedPrinter,
      errorMessage: errorMessage ?? this.errorMessage,
      scanningType: scanningType ?? this.scanningType,
    );
  }
}
