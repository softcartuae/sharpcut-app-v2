   import 'dart:math';

double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }



int generateUniqueInt() {
  final random = Random.secure();
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final randomPart = random.nextInt(1000); // 0–999

  return timestamp * 1000 + randomPart;
}