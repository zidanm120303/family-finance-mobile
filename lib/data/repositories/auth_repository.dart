import 'package:mysql_client/exception.dart';
import 'package:mysql_client/mysql_client.dart';

import '../../core/database/mysql_database_service.dart';
import '../../core/database/sql_queries.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/helpers/password_helper.dart';
import '../../core/helpers/value_parser.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.username,
    required this.phone,
    required this.password,
    required this.familyName,
    required this.city,
    required this.province,
    required this.roleLabel,
  });

  final String name;
  final String email;
  final String username;
  final String phone;
  final String password;
  final String familyName;
  final String city;
  final String province;
  final String roleLabel;
}

class AuthRepository {
  AuthRepository({MysqlDatabaseService? database})
    : _database = database ?? MysqlDatabaseService.instance;

  final MysqlDatabaseService _database;

  Future<UserModel> login({
    required String identity,
    required String password,
  }) async {
    final user = await _database.run<UserModel?>((conn) async {
      final result = await conn.execute(SqlQueries.loginUser, {
        'identity': identity.trim(),
      });
      if (result.rows.isEmpty) return null;
      final row = result.rows.first.typedAssoc();
      final storedHash = row['password']?.toString() ?? '';
      if (!PasswordHelper.verify(password, storedHash)) return null;
      await conn.execute(SqlQueries.updateLastLogin, {'id': row['id']});
      return UserModel.fromRow(row);
    });

    if (user == null) {
      throw const AuthException('Email/username atau password salah.');
    }
    return user;
  }

  Future<UserModel> register(RegisterRequest request) async {
    try {
      return await _database.run<UserModel>((conn) async {
        return conn.transactional<UserModel>((tx) async {
          await _ensureRoles(tx);
          final roleName = request.roleLabel == 'Ayah'
              ? 'Kepala Keluarga'
              : 'Ibu';
          final roleResult = await tx.execute(SqlQueries.getRoleId, {
            'role_name': roleName,
          });
          if (roleResult.rows.isEmpty) {
            throw const AuthException(
              'Role pengguna belum tersedia di database.',
            );
          }
          final roleId = ValueParser.asInt(
            roleResult.rows.first.typedAssoc()['id'],
          );
          final familyCode =
              '${request.familyName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

          final familyResult = await tx.execute(SqlQueries.insertFamily, {
            'family_code': familyCode,
            'family_name': request.familyName.trim(),
            'city': request.city.trim(),
            'province': request.province.trim(),
            'phone': request.phone.trim(),
          });
          final familyId = familyResult.lastInsertID.toInt();

          final userResult = await tx.execute(SqlQueries.insertUser, {
            'family_id': familyId,
            'role_id': roleId,
            'name': request.name.trim(),
            'email': request.email.trim(),
            'username': request.username.trim(),
            'password': PasswordHelper.hash(request.password),
            'phone': request.phone.trim(),
          });
          final userId = userResult.lastInsertID.toInt();

          await tx.execute(SqlQueries.updateFamilyCreator, {
            'user_id': userId,
            'family_id': familyId,
          });
          await tx.execute(SqlQueries.insertDefaultWallet, {
            'family_id': familyId,
          });
          await _insertDefaultCategories(tx, familyId);

          return UserModel(
            id: userId,
            familyId: familyId,
            roleId: roleId,
            name: request.name.trim(),
            email: request.email.trim(),
            username: request.username.trim(),
            phone: request.phone.trim(),
            isActive: true,
            roleName: roleName,
            familyName: request.familyName.trim(),
          );
        });
      });
    } on MySQLServerException catch (error) {
      if (error.errorCode == 1062) {
        throw const AuthException('Email atau username sudah digunakan.');
      }
      rethrow;
    }
  }

  Future<void> _ensureRoles(MySQLConnection conn) async {
    await conn.execute('''
INSERT IGNORE INTO roles (role_name, description, created_at, updated_at)
VALUES
('Kepala Keluarga', 'Pengguna utama keluarga / Ayah', NOW(), NOW()),
('Ibu', 'Pengguna ibu rumah tangga', NOW(), NOW())
''');
  }

  Future<void> _insertDefaultCategories(
    MySQLConnection conn,
    int familyId,
  ) async {
    final categories = <Map<String, String>>[
      {'name': 'Gaji', 'type': 'income', 'icon': 'income', 'color': '#10B981'},
      {'name': 'Bonus', 'type': 'income', 'icon': 'income', 'color': '#2563EB'},
      {'name': 'Usaha', 'type': 'income', 'icon': 'income', 'color': '#8B5CF6'},
      {
        'name': 'Hadiah',
        'type': 'income',
        'icon': 'income',
        'color': '#F59E0B',
      },
      {
        'name': 'Lainnya',
        'type': 'income',
        'icon': 'income',
        'color': '#64748B',
      },
      {
        'name': 'Belanja Rumah Tangga',
        'type': 'expense',
        'icon': 'expense',
        'color': '#EF4444',
      },
      {
        'name': 'Listrik',
        'type': 'expense',
        'icon': 'expense',
        'color': '#F59E0B',
      },
      {
        'name': 'Internet',
        'type': 'expense',
        'icon': 'expense',
        'color': '#2563EB',
      },
      {
        'name': 'Kesehatan',
        'type': 'expense',
        'icon': 'expense',
        'color': '#8B5CF6',
      },
      {
        'name': 'Pendidikan',
        'type': 'expense',
        'icon': 'expense',
        'color': '#2563EB',
      },
      {
        'name': 'Transportasi',
        'type': 'expense',
        'icon': 'expense',
        'color': '#F59E0B',
      },
      {
        'name': 'Makanan & Minuman',
        'type': 'expense',
        'icon': 'expense',
        'color': '#EF4444',
      },
      {
        'name': 'Tagihan',
        'type': 'expense',
        'icon': 'expense',
        'color': '#64748B',
      },
      {
        'name': 'Lainnya',
        'type': 'expense',
        'icon': 'expense',
        'color': '#64748B',
      },
    ];

    for (final item in categories) {
      await conn.execute(SqlQueries.insertCategory, {
        'family_id': familyId,
        'category_name': item['name'],
        'type': item['type'],
        'icon': item['icon'],
        'color': item['color'],
        'description': 'Kategori default ${item['name']}',
      });
    }
  }

  String generateTransactionCode() =>
      DateHelper.transactionCode(DateTime.now());
}
