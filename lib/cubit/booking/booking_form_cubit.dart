import 'package:flutter_bloc/flutter_bloc.dart';

class BookingFormState {
  final String customerName;
  final String customerNumber;

  BookingFormState({this.customerName = '', this.customerNumber = ''});

  BookingFormState copyWith({String? customerName, String? customerNumber}) {
    return BookingFormState(
      customerName: customerName ?? this.customerName,
      customerNumber: customerNumber ?? this.customerNumber,
    );
  }
}

class BookingFormCubit extends Cubit<BookingFormState> {
  BookingFormCubit() : super(BookingFormState());

  void updateName(String name) {
    emit(state.copyWith(customerName: name));
  }

  void updateNumber(String number) {
    emit(state.copyWith(customerNumber: number));
  }

  void reset() {
    emit(BookingFormState());
  }

  void setInitialData({required String name, required String number}) {
    emit(state.copyWith(customerName: name, customerNumber: number));
  }
}
