import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'customer_search_state.dart';

class CustomerSearchCubit extends Cubit<CustomerSearchState> {
  final BookingRepo bookingRepo;

  CustomerSearchCubit(this.bookingRepo) : super(CustomerSearchInitial());

  Future<void> searchCustomer({String? name, String? number}) async {
    if ((name?.length ?? 0) < 3 && (number?.length ?? 0) < 3) {
      emit(CustomerSearchInitial());
      return;
    }
    log("calling search customer");
    emit(CustomerSearchLoading());

    final result = await bookingRepo.searchCustomer(name: name, number: number);

    result.fold(
      (error) => emit(CustomerSearchError(error)),
      (suggestions) => emit(CustomerSearchSuccess(suggestions)),
    );
  }

  void reset() {
    emit(CustomerSearchInitial());
  }
}
