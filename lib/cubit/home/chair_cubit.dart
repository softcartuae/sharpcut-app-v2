import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/domain/home/chair/chair_repo.dart';

class ChairCubit extends Cubit<ChairState> {
  final ChairRepo chairRepo;

  ChairCubit({required this.chairRepo}) : super(ChairInitial());

  List<ChairModel>? _cachedChairs;
  List<StaffModel>? _cachedStaffs;

  List<StaffModel> get staffs => _cachedStaffs ?? [];

  Future<void> getChairsAndStaffs() async {
    if (_cachedChairs != null && _cachedStaffs != null) {
      emit(ChairSuccess(chairs: _cachedChairs!, staffs: _cachedStaffs!));
      return;
    }

    emit(ChairLoading());
    try {
      final result = await chairRepo.getChairsAndStaffs();
      _cachedChairs = result.chairs;
      _cachedStaffs = result.staffs;
      emit(ChairSuccess(chairs: result.chairs, staffs: result.staffs));
    } catch (e) {
      emit(ChairError(message: e.toString()));
    }
  }
}
