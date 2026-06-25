import '../../core/database/mysql_database_service.dart';
import '../../core/database/sql_queries.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/helpers/value_parser.dart';
import '../models/transaction_model.dart';

class TransactionException implements Exception {
  const TransactionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CreateTransactionRequest {
  const CreateTransactionRequest({
    required this.familyId,
    required this.userId,
    required this.categoryId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.title,
    required this.transactionDate,
    required this.paymentMethod,
    this.description,
    this.allowMinusBalance = false,
  });

  final int familyId;
  final int userId;
  final int categoryId;
  final int walletId;
  final String type;
  final double amount;
  final String title;
  final DateTime transactionDate;
  final String paymentMethod;
  final String? description;
  final bool allowMinusBalance;
}

class HistoryResult {
  const HistoryResult({
    required this.items,
    required this.totalIncome,
    required this.totalExpense,
  });

  final List<TransactionModel> items;
  final double totalIncome;
  final double totalExpense;
}

class TransactionRepository {
  TransactionRepository({MysqlDatabaseService? database})
    : _database = database ?? MysqlDatabaseService.instance;

  final MysqlDatabaseService _database;

  Future<void> create(CreateTransactionRequest request) {
    return _database.run((conn) async {
      await conn.transactional((tx) async {
        if (request.type == 'expense' && !request.allowMinusBalance) {
          final balanceResult = await tx.execute(SqlQueries.walletBalance, {
            'wallet_id': request.walletId,
            'family_id': request.familyId,
          });
          final balance = balanceResult.rows.isEmpty
              ? 0.0
              : ValueParser.asDouble(
                  balanceResult.rows.first.typedAssoc()['balance'],
                );
          if (balance < request.amount) {
            throw const TransactionException(
              'Saldo dompet tidak cukup. Aktifkan izin saldo minus untuk tetap simpan transaksi.',
            );
          }
        }

        final insert = await tx.execute(SqlQueries.insertTransaction, {
          'family_id': request.familyId,
          'user_id': request.userId,
          'category_id': request.categoryId,
          'wallet_id': request.walletId,
          'transaction_code': DateHelper.transactionCode(DateTime.now()),
          'type': request.type,
          'amount': request.amount,
          'title': request.title.trim(),
          'description': request.description?.trim(),
          'transaction_date': DateHelper.inputDate(request.transactionDate),
          'payment_method': request.paymentMethod,
        });

        final updateQuery = request.type == 'income'
            ? SqlQueries.updateWalletIncome
            : SqlQueries.updateWalletExpense;
        await tx.execute(updateQuery, {
          'amount': request.amount,
          'wallet_id': request.walletId,
          'family_id': request.familyId,
        });

        await tx.execute(SqlQueries.insertHistory, {
          'transaction_id': insert.lastInsertID.toInt(),
          'user_id': request.userId,
          'note': 'Transaksi dibuat dari aplikasi mobile',
        });
      });
    });
  }

  Future<HistoryResult> history({
    required int familyId,
    required DateTime month,
    String type = 'all',
    String search = '',
    int limit = 100,
    int offset = 0,
  }) {
    return _database.run((conn) async {
      final params = <String, dynamic>{
        'family_id': familyId,
        'month': month.month,
        'year': month.year,
        'limit_value': limit,
        'offset_value': offset,
      };
      final filters = <String>[
        't.family_id = :family_id',
        'MONTH(t.transaction_date) = :month',
        'YEAR(t.transaction_date) = :year',
      ];

      if (type == 'income' || type == 'expense') {
        filters.add('t.type = :type');
        params['type'] = type;
      }

      if (search.trim().isNotEmpty) {
        filters.add('''
(t.title LIKE :search OR t.description LIKE :search OR c.category_name LIKE :search OR t.transaction_code LIKE :search)
''');
        params['search'] = '%${search.trim()}%';
      }

      final whereClause = filters.join(' AND ');
      final query =
          '''
SELECT t.*, c.category_name, c.icon, c.color, w.wallet_name, u.name AS user_name
FROM transactions t
LEFT JOIN categories c ON t.category_id = c.id
LEFT JOIN wallets w ON t.wallet_id = w.id
LEFT JOIN users u ON t.user_id = u.id
WHERE $whereClause
ORDER BY t.transaction_date DESC, t.id DESC
LIMIT :limit_value OFFSET :offset_value
''';

      final summaryQuery =
          '''
SELECT
  COALESCE(SUM(CASE WHEN t.type = 'income' AND t.status = 'success' THEN t.amount ELSE 0 END), 0) AS total_income,
  COALESCE(SUM(CASE WHEN t.type = 'expense' AND t.status = 'success' THEN t.amount ELSE 0 END), 0) AS total_expense
FROM transactions t
LEFT JOIN categories c ON t.category_id = c.id
WHERE $whereClause
''';

      final rows = await conn.execute(query, params);
      final summary = await conn.execute(summaryQuery, params);
      final summaryRow = summary.rows.first.typedAssoc();

      return HistoryResult(
        items: rows.rows
            .map((row) => TransactionModel.fromRow(row.typedAssoc()))
            .toList(),
        totalIncome: ValueParser.asDouble(summaryRow['total_income']),
        totalExpense: ValueParser.asDouble(summaryRow['total_expense']),
      );
    });
  }

  Future<TransactionModel> detail({required int id, required int familyId}) {
    return _database.run((conn) async {
      final result = await conn.execute(SqlQueries.transactionDetail, {
        'id': id,
        'family_id': familyId,
      });
      if (result.rows.isEmpty) {
        throw const TransactionException('Transaksi tidak ditemukan.');
      }
      return TransactionModel.fromRow(result.rows.first.typedAssoc());
    });
  }
}
