import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';

abstract class ChairRepo {
  Future<List<ChairModel>> getChairs();
  Future<({List<ChairModel> chairs, List<StaffModel> staffs})>
  getChairsAndStaffs();
}
