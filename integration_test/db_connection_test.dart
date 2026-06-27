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

  testWidgets('creates and joins a family against the FlyEnv schema', (
    _,
  ) async {
    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final repository = AuthRepository();
    final familyName = 'Keluarga Tes $suffix';
    int? familyId;

    try {
      final father = await repository.register(
        RegisterRequest(
          name: 'Tes Ayah',
          email: 'father.$suffix@example.test',
          username: 'father_$suffix',
          phone: '081234567890',
          password: 'password123',
          familyName: familyName,
          city: 'Ciamis',
          province: 'Jawa Barat',
          roleLabel: 'Ayah',
        ),
      );
      familyId = father.familyId;

      await expectLater(
        repository.register(
          RegisterRequest(
            name: 'Tes Ayah Duplikat',
            email: 'duplicate.$suffix@example.test',
            username: 'duplicate_$suffix',
            phone: '081234567892',
            password: 'password123',
            familyName: familyName,
            city: 'Ciamis',
            province: 'Jawa Barat',
            roleLabel: 'Ayah',
          ),
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            contains('sudah digunakan'),
          ),
        ),
      );

      final mother = await repository.register(
        RegisterRequest(
          name: 'Tes Ibu',
          email: 'mother.$suffix@example.test',
          username: 'mother_$suffix',
          phone: '081234567891',
          password: 'password123',
          familyName: familyName,
          city: '',
          province: '',
          roleLabel: 'Ibu Rumah Tangga',
        ),
      );

      final result = await MysqlDatabaseService.instance.run((conn) async {
        final family = await conn.execute(
          '''
SELECT address, postal_code
FROM families
WHERE id = :family_id
''',
          {'family_id': familyId},
        );
        final users = await conn.execute(
          'SELECT COUNT(*) AS total FROM users WHERE family_id = :family_id',
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
          'users': users.rows.single.typedAssoc()['total'],
          'wallets': wallets.rows.single.typedAssoc()['total'],
          'categories': categories.rows.single.typedAssoc()['total'],
        };
      });

      expect(mother.familyId, father.familyId);
      expect(mother.familyName, familyName);
      expect(mother.roleName, 'Ibu');
      final family = result['family']! as Map<String, dynamic>;
      expect(family['address'], 'Ciamis, Jawa Barat');
      expect(family['postal_code'], '');
      expect(int.parse(result['users'].toString()), 2);
      expect(int.parse(result['wallets'].toString()), 1);
      expect(int.parse(result['categories'].toString()), 14);
    } finally {
      if (familyId != null) {
        await MysqlDatabaseService.instance.run((conn) async {
          await conn.transactional((tx) async {
            await tx.execute('DELETE FROM users WHERE family_id = :family_id', {
              'family_id': familyId,
            });
            await tx.execute('DELETE FROM families WHERE id = :family_id', {
              'family_id': familyId,
            });
          });
        });
      }
    }
  });

  testWidgets('rejects joining an unknown family', (_) async {
    final suffix = DateTime.now().microsecondsSinceEpoch.toString();

    await expectLater(
      AuthRepository().register(
        RegisterRequest(
          name: 'Tes Ibu',
          email: 'unknown.$suffix@example.test',
          username: 'unknown_$suffix',
          phone: '081234567891',
          password: 'password123',
          familyName: 'Keluarga Tidak Ada $suffix',
          city: '',
          province: '',
          roleLabel: 'Ibu Rumah Tangga',
        ),
      ),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          contains('tidak ditemukan'),
        ),
      ),
    );
  });
}
