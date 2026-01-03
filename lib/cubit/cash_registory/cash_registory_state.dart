abstract class CashRegistoryState {}

class CashRegistoryInitial extends CashRegistoryState {}

class CashRegistoryLoading extends CashRegistoryState {}

class CashRegistoryAddSuccess extends CashRegistoryState {
  final String message;
  CashRegistoryAddSuccess(this.message);
}

class CashRegistorOpen extends CashRegistoryState {
  final String message;
  CashRegistorOpen(this.message);
}

class CashRegistorClosed extends CashRegistoryState {
  final String message;
  CashRegistorClosed(this.message);
}

class CashRegistoryAddError extends CashRegistoryState {
  final String message;
  CashRegistoryAddError(this.message);
}

class CashRegistorySalesTotalLoaded extends CashRegistoryState {
  final double totalSales;
  CashRegistorySalesTotalLoaded(this.totalSales);
}
