import 'package:sharp_cut/utils/helpers/enums.dart';

class StaffModel {
  final int id;
  final String name;
  final Role role ;

  StaffModel({required this.id, required this.name, this.role = Role.staff});

  factory StaffModel.fromJson(Map<String, dynamic> json,{Role role = Role.staff}) {
    return StaffModel(id: json['id'], name: json['name'] ?? "not available", role: role);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
