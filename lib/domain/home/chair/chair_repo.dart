import 'package:sharp_cut/domain/home/models/chair_model.dart';

abstract class ChairRepo {
  Future<List<ChairModel>> getChairs();
}
