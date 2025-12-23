import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepo bookingRepo;

  BookingCubit({required this.bookingRepo}) : super(BookingInitial());

  Future<void> bookSlot({
    required int chairId,
    required int userId,
    required String userPassword,
  }) async {
    emit(BookingLoading());
    final result = await bookingRepo.bookSlot(
      chairId: chairId,
      userId: userId,
      userPassword: userPassword,
    );
    result.fold(
      (error) => emit(BookingError(message: error)),
      (bookingResponse) =>
          emit(BookingSuccess(bookingResponse: bookingResponse)),
    );
  }
}
