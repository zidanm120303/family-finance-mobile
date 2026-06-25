import '../../core/helpers/date_helper.dart';
import '../../core/helpers/value_parser.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.categoryId,
    required this.transactionCode,
    required this.type,
    required this.amount,
    required this.title,
    required this.transactionDate,
    required this.paymentMethod,
    required this.status,
    this.walletId,
    this.description,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.walletName,
    this.userName,
  });

  final int id;
  final int familyId;
  final int userId;
  final int categoryId;
  final int? walletId;
  final String transactionCode;
  final String type;
  final double amount;
  final String title;
  final String? description;
  final DateTime transactionDate;
  final String paymentMethod;
  final String status;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? walletName;
  final String? userName;

  bool get isIncome => type == 'income';
  String get typeLabel => isIncome ? 'Pemasukan' : 'Pengeluaran';
  String get paymentMethodLabel => switch (paymentMethod) {
    'bank' => 'Bank',
    'e-wallet' => 'E-Wallet',
    _ => 'Cash',
  };

  factory TransactionModel.fromRow(Map<String, dynamic> row) {
    return TransactionModel(
      id: ValueParser.asInt(row['id']),
      familyId: ValueParser.asInt(row['family_id']),
      userId: ValueParser.asInt(row['user_id']),
      categoryId: ValueParser.asInt(row['category_id']),
      walletId: ValueParser.asNullableInt(row['wallet_id']),
      transactionCode: ValueParser.asString(row['transaction_code']),
      type: ValueParser.asString(row['type']),
      amount: ValueParser.asDouble(row['amount']),
      title: ValueParser.asString(row['title']),
      description: row['description']?.toString(),
      transactionDate: DateHelper.parseDate(row['transaction_date']),
      paymentMethod: ValueParser.asString(
        row['payment_method'],
        fallback: 'cash',
      ),
      status: ValueParser.asString(row['status'], fallback: 'success'),
      categoryName: row['category_name']?.toString(),
      categoryIcon: row['icon']?.toString(),
      categoryColor: row['color']?.toString(),
      walletName: row['wallet_name']?.toString(),
      userName: row['user_name']?.toString(),
    );
  }
}
