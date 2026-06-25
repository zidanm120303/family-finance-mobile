import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  static final DateFormat _date = DateFormat('d MMMM yyyy', 'id_ID');
  static final DateFormat _shortDate = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _month = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _input = DateFormat('yyyy-MM-dd');
  static final DateFormat _code = DateFormat('yyyyMMdd-HHmmss');

  static String formatDate(DateTime date) => _date.format(date);

  static String formatShortDate(DateTime date) => _shortDate.format(date);

  static String formatMonth(DateTime date) => _month.format(date);

  static String inputDate(DateTime date) => _input.format(date);

  static String transactionCode(DateTime date) => 'TRX-${_code.format(date)}';

  static DateTime parseDate(dynamic value) {
    if (value is DateTime) return value;
    final text = value?.toString();
    if (text == null || text.isEmpty) return DateTime.now();
    return DateTime.tryParse(text) ?? _input.parse(text);
  }
}
