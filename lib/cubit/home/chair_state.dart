import 'package:sharp_cut/domain/home/models/chair_model.dart';

abstract class ChairState {}

class ChairInitial extends ChairState {}

class ChairLoading extends ChairState {}

class ChairSuccess extends ChairState {
  final List<ChairModel> chairs;
  ChairSuccess({required this.chairs});
}

class ChairError extends ChairState {
  final String message;
  ChairError({required this.message});
}
