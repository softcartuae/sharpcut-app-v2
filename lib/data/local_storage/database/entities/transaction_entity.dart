class TransactionEntity {
  final int? id;
  final int? chairId;
  final String? customerName;
  final String? customerNumber;
  final double? grandTotal;
  final double? taxTotal;
  final double? discount;
  final double? roundOff;
  final double? finalTotal;
  final double? finalTotalBefore;
  final String? paymentStatus;
  final String? status;
  final String? createdAt;

  TransactionEntity({
    this.id,
    this.chairId,
    this.customerName,
    this.customerNumber,
    this.grandTotal,
    this.taxTotal,
    this.discount,
    this.roundOff,
    this.finalTotal,
    this.finalTotalBefore,
    this.paymentStatus,
    this.status,
    this.createdAt,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as int?,
      chairId: json['chair_id'] as int?,
      customerName: json['customer_name'] as String?,
      customerNumber: json['customer_number'] as String?,
      grandTotal: (json['grand_total'] as num?)?.toDouble(),
      taxTotal: (json['tax_total'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      roundOff: (json['round_off'] as num?)?.toDouble(),
      finalTotal: (json['final_total'] as num?)?.toDouble(),
      finalTotalBefore: (json['final_total_before'] as num?)?.toDouble(),
      paymentStatus: json['payment_status'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chair_id': chairId,
      'customer_name': customerName,
      'customer_number': customerNumber,
      'grand_total': grandTotal,
      'tax_total': taxTotal,
      'discount': discount,
      'round_off': roundOff,
      'final_total': finalTotal,
      'final_total_before': finalTotalBefore,
      'payment_status': paymentStatus,
      'status': status,
      'created_at': createdAt,
    };
  }
}
