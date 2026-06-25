import '../../core/database/mysql_database_service.dart';
import '../../core/database/sql_queries.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  WalletRepository({MysqlDatabaseService? database})
    : _database = database ?? MysqlDatabaseService.instance;

  final MysqlDatabaseService _database;

  Future<List<WalletModel>> byFamily(int familyId) {
    return _database.run((conn) async {
      final result = await conn.execute(SqlQueries.walletsByFamily, {
        'family_id': familyId,
      });
      return result.rows
          .map((row) => WalletModel.fromRow(row.typedAssoc()))
          .toList();
    });
  }
}
