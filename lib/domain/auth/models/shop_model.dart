class ShopModel {
  final int? id;
  final String? name;
  final String? description;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? contactNo;
  final String? licenseNo;
  final String? vatNo;
  final String? logo;
  final String? floorArea;
  final String? currency;
  final int? isChair;
  final String? subscriptionEndDate;
  final int? status;
  final String? startTime;
  final String? endTime;
  final int? overNight;
  final int? syncDuration;
  final String? createdAt;
  final String? updatedAt;

  ShopModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.city,
    this.zipCode,
    this.contactNo,
    this.licenseNo,
    this.vatNo,
    this.logo,
    this.floorArea,
    this.currency,
    this.isChair,
    this.subscriptionEndDate,
    this.status,
    this.startTime,
    this.endTime,
    this.overNight,
    this.syncDuration,
    this.createdAt,
    this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      zipCode: json['zip_code'],
      contactNo: json['contact_no'],
      licenseNo: json['license_no'],
      vatNo: json['vat_no'],
      logo: json['logo'],
      floorArea: json['floor_area'],
      currency: json['currency'],
      isChair: json['is_chair'],
      subscriptionEndDate: json['subscription_end_date'],
      status: json['status'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      overNight: json['over_night'],
      syncDuration: json['sync_duration'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'zip_code': zipCode,
      'contact_no': contactNo,
      'license_no': licenseNo,
      'vat_no': vatNo,
      'logo': logo,
      'floor_area': floorArea,
      'currency': currency,
      'is_chair': isChair,
      'subscription_end_date': subscriptionEndDate,
      'status': status,
      'start_time': startTime,
      'end_time': endTime,
      'over_night': overNight,
      'sync_duration': syncDuration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
