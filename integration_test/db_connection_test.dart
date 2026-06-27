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

  testWidgets('registers a family against the FlyEnv schema', (_) async {
    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final repository = AuthRepository();
    int? userId;
    int? familyId;

    try {
      final user = await repository.register(
        RegisterRequest(
          name: 'Tes Registrasi',
          email: 'register.$suffix@example.test',
          username: 'register_$suffix',
          phone: '081234567890',
          password: 'password123',
          familyName: 'Keluarga Tes $suffix',
          city: 'Ciamis',
          province: 'Jawa Barat',
          roleLabel: 'Ayah',
        ),
      );
      userId = user.id;
      familyId = user.familyId;

      final result = await MysqlDatabaseService.instance.run((conn) async {
        final family = await conn.execute(
          '''
SELECT address, postal_code
FROM families
WHERE id = :family_id
''',
          {'family_id': familyId},
        );
        final wallets = await conn.execute(
          'SELECT COUNT(*) AS total FROM wallets WHERE family_id = :family_id',
          {'family_id': familyId},
        );
        final categories = await conn.execute(
          '''
SELECT COUNT(*) AS total
FROM categories
WHERE family_id = :family_id
''',
          {'family_id': familyId},
        );

        return {
          'family': family.rows.single.typedAssoc(),
          'wallets': wallets.rows.single.typedAssoc()['total'],
          'categories': categories.rows.single.typedAssoc()['total'],
        };
      });

      final family = result['family']! as Map<String, dynamic>;
      expect(family['address'], 'Ciamis, Jawa Barat');
      expect(family['postal_code'], '');
      expect(int.parse(result['wallets'].toString()), 1);
      expect(int.parse(result['categories'].toString()), 14);
    } finally {
      if (userId != null && familyId != null) {
        await MysqlDatabaseService.instance.run((conn) async {
          await conn.transactional((tx) async {
            await tx.execute('DELETE FROM users WHERE id = :id', {
              'id': userId,
            });
            await tx.execute('DELETE FROM families WHERE id = :id', {
              'id': familyId,
            });
          });
        });
      }
    }
  });
}
