import 'package:sharp_cut/utils/helpers/enums.dart';

class StaffModel {
  final int id;
  final String name;
  final String shortname;
  final Role role;
  final String? photo;

  // final ProfileModel? profile;

  StaffModel({
    required this.id,
    required this.name,
    required this.shortname,
    this.role = Role.staff,
    // this.profile,
    this.photo,
  });

  factory StaffModel.fromJson(
    Map<String, dynamic> json, {
    Role role = Role.staff,
  }) {
    return StaffModel(
      id: json['id'],
      name: json['name'] ?? "not available",
      shortname: json['short_name'] ?? "not available",
      role: role,
      photo: json['photo'],
      // profile: json['profile'] != null
      //     ? ProfileModel.fromJson(json['profile'])
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'short_name': shortname, 'photo': photo};
  }
}

// class ProfileModel {
//   final int? id;
//   final int? userId;
//   final String? contactNo;
//   final String? photo;

//   ProfileModel({this.id, this.userId, this.contactNo, this.photo});

//   factory ProfileModel.fromJson(Map<String, dynamic> json) {
//     return ProfileModel(
//       id: json['id'],
//       userId: json['user_id'],
//       contactNo: json['contact_no'],
//       photo: json['photo'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'contact_no': contactNo,
//       'photo': photo,
//     };
//   }
// }
