class PrinterSettingsModel {
  final PrintCount printCount;
  final OpenDrawer openDrawer;

  const PrinterSettingsModel({
    required this.printCount,
    required this.openDrawer,
  });

  factory PrinterSettingsModel.fromJson(Map<String, dynamic> json) {
    return PrinterSettingsModel(
      printCount: PrintCount.fromJson(json['print_count'] ?? {}),
      openDrawer: OpenDrawer.fromJson(json['open_drawer'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'print_count': printCount.toJson(),
      'open_drawer': openDrawer.toJson(),
    };
  }

  PrinterSettingsModel copyWith({
    PrintCount? printCount,
    OpenDrawer? openDrawer,
  }) {
    return PrinterSettingsModel(
      printCount: printCount ?? this.printCount,
      openDrawer: openDrawer ?? this.openDrawer,
    );
  }
}

class PrintCount {
  final int quickPayment;
  final int settlePayment;
  final int report;
  final int invoiceList;

  const PrintCount({
    required this.quickPayment,
    required this.settlePayment,
    required this.report,
    required this.invoiceList,
  });

  factory PrintCount.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 1;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 1;
      return 1;
    }

    return PrintCount(
      quickPayment: toInt(json['quick_payment']),
      settlePayment: toInt(json['settle_payment']),
      report: toInt(json['report']),
      invoiceList: toInt(json['invoice_list']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quick_payment': quickPayment,
      'settle_payment': settlePayment,
      'report': report,
      'invoice_list': invoiceList,
    };
  }
}

class OpenDrawer {
  final bool cash;
  final bool card;

  const OpenDrawer({required this.cash, required this.card});

  factory OpenDrawer.fromJson(Map<String, dynamic> json) {
    bool toBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    return OpenDrawer(cash: toBool(json['cash']), card: toBool(json['card']));
  }

  Map<String, dynamic> toJson() {
    return {'cash': cash, 'card': card};
  }

  OpenDrawer copyWith({bool? cash, bool? card}) {
    return OpenDrawer(cash: cash ?? this.cash, card: card ?? this.card);
  }
}
