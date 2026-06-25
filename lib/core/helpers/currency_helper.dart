import 'package:intl/intl.dart';

class CurrencyHelper {
  CurrencyHelper._();

  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num value, {bool withSign = false, String? type}) {
    final prefix = withSign
        ? switch (type) {
            'income' => '+',
            'expense' => '-',
            _ => '',
          }
        : '';
    return '$prefix${_rupiah.format(value.abs())}';
  }

  static double parseInput(String input) {
    final normalized = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }
}
