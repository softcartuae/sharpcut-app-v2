part of 'printing_cubit.dart';

enum PrintingStatus { initial, scanning, connecting, connected, error }

class PrintingState {
  final PrintingStatus status;
  final List<Printer> printers;
  final Printer? connectedPrinter;
  final String? errorMessage;

  PrintingState({
    this.status = PrintingStatus.initial,
    this.printers = const [],
    this.connectedPrinter,
    this.errorMessage,
  });

  PrintingState copyWith({
    PrintingStatus? status,
    List<Printer>? printers,
    Printer? connectedPrinter,
    String? errorMessage,
  }) {
    return PrintingState(
      status: status ?? this.status,
      printers: printers ?? this.printers,
      connectedPrinter: connectedPrinter ?? this.connectedPrinter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
