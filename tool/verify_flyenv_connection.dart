// ignore_for_file: avoid_print

import 'package:famfinance_mobile/core/database/db_config.dart';
import 'package:famfinance_mobile/core/database/mysql_database_service.dart';

Future<void> main() async {
  final info = await MysqlDatabaseService.instance.run((conn) async {
    final database = await conn.execute('SELECT DATABASE() AS db_name');
    final users = await conn.execute(
      'SELECT COUNT(*) AS users_count FROM users',
    );
    final transactions = await conn.execute("SHOW TABLES LIKE 'transactions'");

    return {
      'database': database.rows.first.typedAssoc()['db_name'],
      'users': users.rows.first.typedAssoc()['users_count'],
      'hasTransactions': transactions.rows.isNotEmpty,
    };
  });

  print('FlyEnv MySQL connection OK');
  print('Host candidates: ${DbConfig.hostCandidates.join(', ')}');
  print('Database: ${info['database']}');
  print('Users count: ${info['users']}');
  print('Transactions table: ${info['hasTransactions']}');
}
