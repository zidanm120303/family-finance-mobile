import 'package:famfinance_mobile/core/database/db_config.dart';
import 'package:famfinance_mobile/core/database/mysql_database_service.dart';
import 'package:famfinance_mobile/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('connects to FlyEnv MySQL from device', (_) async {
    final result = await MysqlDatabaseService.instance.run((conn) async {
      final database = await conn.execute('SELECT DATABASE() AS db_name');
      final users = await conn.execute(
        'SELECT COUNT(*) AS users_count FROM users',
      );
      final transactions = await conn.execute(
        "SHOW TABLES LIKE 'transactions'",
      );

      return {
        'database': database.rows.first.typedAssoc()['db_name'],
        'users': users.rows.first.typedAssoc()['users_count'],
        'hasTransactions': transactions.rows.isNotEmpty,
        'hosts': DbConfig.hostCandidates.join(', '),
      };
    });

    expect(result['database'], 'family_finance');
    expect(result['hasTransactions'], true);
  });

  testWidgets('logs in seeded FlyEnv user from device', (_) async {
    final user = await AuthRepository().login(
      identity: 'budi.pratama@email.com',
      password: 'password',
    );

    expect(user.name, 'Budi Pratama');
    expect(user.familyName, 'Keluarga Pratama');
  });
}
