import '../../core/database/mysql_database_service.dart';
import '../../core/database/sql_queries.dart';
import '../../core/helpers/value_parser.dart';
import '../models/home_summary_model.dart';
import '../models/transaction_model.dart';

class HomeRepository {
  HomeRepository({MysqlDatabaseService? database})
    : _database = database ?? MysqlDatabaseService.instance;

  final MysqlDatabaseService _database;

  Future<HomeSummaryModel> getSummary(int familyId) {
    final now = DateTime.now();
    return _database.run((conn) async {
      final balance = await conn.execute(SqlQueries.totalBalance, {
        'family_id': familyId,
      });
      final income = await conn.execute(SqlQueries.incomeMonth, {
        'family_id': familyId,
        'month': now.month,
        'year': now.year,
      });
      final expense = await conn.execute(SqlQueries.expenseMonth, {
        'family_id': familyId,
        'month': now.month,
        'year': now.year,
      });
      final recent = await conn.execute(SqlQueries.recentTransactions, {
        'family_id': familyId,
      });

      return HomeSummaryModel(
        totalBalance: ValueParser.asDouble(
          balance.rows.first.typedAssoc()['total_balance'],
        ),
        monthIncome: ValueParser.asDouble(
          income.rows.first.typedAssoc()['total_income'],
        ),
        monthExpense: ValueParser.asDouble(
          expense.rows.first.typedAssoc()['total_expense'],
        ),
        recentTransactions: recent.rows
            .map((row) => TransactionModel.fromRow(row.typedAssoc()))
            .toList(),
      );
    });
  }
}
