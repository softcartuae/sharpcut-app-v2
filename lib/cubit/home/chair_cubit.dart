import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/home/chair/chair_repo.dart';

class ChairCubit extends Cubit<ChairState> {
  final ChairRepo chairRepo;

  ChairCubit({required this.chairRepo}) : super(ChairInitial());

  List<ChairModel>? _cachedChairs;
  Future<void> getChairs() async {
    if (_cachedChairs != null) {
      emit(ChairSuccess(chairs: _cachedChairs!));
      return;
    }

    emit(ChairLoading());
    try {
      final chairs = await chairRepo.getChairs();
      _cachedChairs = chairs;
      emit(ChairSuccess(chairs: chairs));
    } catch (e) {
      emit(ChairError(message: e.toString()));
    }
  }
}
