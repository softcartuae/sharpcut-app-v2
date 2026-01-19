import 'package:sharp_cut/utils/helpers/convertion.dart';

class CashRegisterModel {
  final int? id;
  final int? openedBy;
  final int? closedBy;
  final String? openedByType;
  final String? closedByType;
  final double? openingAmount;
  final double? closingAmount;
  final String? openedAt;
  final String? closedAt;
  final String? createdAt;
  final String? updatedAt;
  final int? isSynced;

  CashRegisterModel({
    this.id,
    this.openedBy,
    this.closedBy,
    this.openedByType,
    this.closedByType,
    this.openingAmount,
    this.closingAmount,
    this.openedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
    this.isSynced,
  });

  factory CashRegisterModel.fromJson(Map<String, dynamic> json) {
    return CashRegisterModel(
      id: json['id'],
      openedBy: json['opened_by'],
      closedBy: json['closed_by'],
      openedByType: json['opened_by_type'],
      closedByType: json['closed_by_type'],
      openingAmount: toDouble(json['opening_amount']),
      closingAmount: toDouble(json['closing_amount']),
      openedAt: json['opened_at'],
      closedAt: json['closed_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isSynced: json['is_synced'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opened_by': openedBy,
      'closed_by': closedBy,
      'opened_by_type': openedByType,
      'closed_by_type': closedByType,
      'opening_amount': openingAmount,
      'closing_amount': closingAmount,
      'opened_at': openedAt,
      'closed_at': closedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }
}
