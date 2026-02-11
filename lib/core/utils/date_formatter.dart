import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
  
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

   static String dateonly(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String now() {
    return format(DateTime.now());
  }
}
