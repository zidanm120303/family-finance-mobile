import '../../core/helpers/value_parser.dart';

class WalletModel {
  const WalletModel({
    required this.id,
    required this.familyId,
    required this.walletName,
    required this.balance,
    required this.type,
    this.accountNumber,
  });

  final int id;
  final int familyId;
  final String walletName;
  final double balance;
  final String type;
  final String? accountNumber;

  String get typeLabel => switch (type) {
    'bank' => 'Bank',
    'e-wallet' => 'E-Wallet',
    _ => 'Cash',
  };

  factory WalletModel.fromRow(Map<String, dynamic> row) {
    return WalletModel(
      id: ValueParser.asInt(row['id']),
      familyId: ValueParser.asInt(row['family_id']),
      walletName: ValueParser.asString(row['wallet_name']),
      balance: ValueParser.asDouble(row['balance']),
      type: ValueParser.asString(row['type'], fallback: 'cash'),
      accountNumber: row['account_number']?.toString(),
    );
  }
}
