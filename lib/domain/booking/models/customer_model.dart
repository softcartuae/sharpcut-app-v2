import 'package:sharp_cut/utils/helpers/convertion.dart';

class CustomerModel {
  final int? id;
  final String? firebaseUid;
  final String? phoneNumber;
  final String? name;
  final String? email;
  final String? gender;
  final double? wallet;
  final double? discount;
  final String? validUpTo;
  final String? address;

  CustomerModel({
    this.id,
    this.firebaseUid,
    this.phoneNumber,
    this.name,
    this.email,
    this.gender,
    this.wallet,
    this.discount,
    this.validUpTo,
    this.address,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      firebaseUid: json['firebase_uid'],
      phoneNumber: json['phone_number'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      wallet: toDouble(json['wallet']),
      discount: toDouble(json['discount']),
      validUpTo: json['valid_up_to'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'phone_number': phoneNumber,
      'name': name,
      'email': email,
      'gender': gender,
      'wallet': wallet,
      'discount': discount,
      'valid_up_to': validUpTo,
      'address': address,
    };
  }
}
