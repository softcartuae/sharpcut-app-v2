class StaffModel {
  final int id;
  final String name;

  StaffModel({required this.id, required this.name});

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(id: json['id'], name: json['name'] ?? "not available");
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
