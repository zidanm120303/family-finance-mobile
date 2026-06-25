import 'transaction_model.dart';

class HomeSummaryModel {
  const HomeSummaryModel({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.recentTransactions,
  });

  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  final List<TransactionModel> recentTransactions;

  static const empty = HomeSummaryModel(
    totalBalance: 0,
    monthIncome: 0,
    monthExpense: 0,
    recentTransactions: [],
  );
}
