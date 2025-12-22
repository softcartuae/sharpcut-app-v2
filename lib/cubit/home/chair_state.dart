import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';

abstract class ChairState {}

class ChairInitial extends ChairState {}

class ChairLoading extends ChairState {}

class ChairSuccess extends ChairState {
  final List<ChairModel> chairs;
  final List<StaffModel> staffs;
  ChairSuccess({required this.chairs, this.staffs = const []});
}

class ChairError extends ChairState {
  final String message;
  ChairError({required this.message});
}
