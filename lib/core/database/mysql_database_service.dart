import 'dart:async';
import 'dart:io';

import 'package:mysql_client/exception.dart';
import 'package:mysql_client/mysql_client.dart';

import 'db_config.dart';

class AppDatabaseException implements Exception {
  const AppDatabaseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MysqlDatabaseService {
  MysqlDatabaseService._();

  static final MysqlDatabaseService instance = MysqlDatabaseService._();

  Future<MySQLConnection> _openConnection() async {
    Object? lastError;

    for (final host in DbConfig.hostCandidates) {
      MySQLConnection? connection;
      try {
        connection = await MySQLConnection.createConnection(
          host: host,
          port: DbConfig.port,
          userName: DbConfig.username,
          password: DbConfig.password,
          databaseName: DbConfig.database,
          secure: true,
        ).timeout(const Duration(seconds: 4));
        await connection.connect().timeout(const Duration(seconds: 4));
        return connection;
      } catch (error) {
        lastError = error;
        try {
          await connection?.close();
        } catch (_) {}
      }
    }

    Error.throwWithStackTrace(
      AppDatabaseException(
        'Database tidak terhubung. Periksa koneksi MySQL dan jaringan Anda.'
        '${lastError == null ? '' : ' Detail: $lastError'}',
      ),
      StackTrace.current,
    );
  }

  Future<T> run<T>(Future<T> Function(MySQLConnection conn) action) async {
    MySQLConnection? conn;
    try {
      conn = await _openConnection();
      return await action(conn).timeout(const Duration(seconds: 15));
    } on AppDatabaseException {
      rethrow;
    } on TimeoutException {
      throw const AppDatabaseException(
        'Database tidak terhubung. Periksa koneksi MySQL dan jaringan Anda.',
      );
    } on SocketException catch (error) {
      throw AppDatabaseException(
        'Database tidak terhubung. Periksa koneksi MySQL dan jaringan Anda. Detail: $error',
      );
    } on MySQLClientException {
      throw const AppDatabaseException(
        'Database tidak terhubung. Periksa koneksi MySQL dan jaringan Anda.',
      );
    } catch (_) {
      rethrow;
    } finally {
      try {
        await conn?.close();
      } catch (_) {}
    }
  }
}
