class DbConfig {
  const DbConfig._();

  static const String host = String.fromEnvironment(
    'DB_HOST',
    defaultValue: '10.0.2.2',
  );
  static const int port = int.fromEnvironment('DB_PORT', defaultValue: 3306);
  static const String database = String.fromEnvironment(
    'DB_NAME',
    defaultValue: 'family_finance',
  );
  static const String username = String.fromEnvironment(
    'DB_USER',
    defaultValue: 'root',
  );
  static const String password = String.fromEnvironment(
    'DB_PASSWORD',
    defaultValue: 'root',
  );

  static List<String> get hostCandidates {
    final normalized = host.toLowerCase();
    final isLocal =
        normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '10.0.2.2';
    if (!isLocal) return [host];

    final candidates = <String>[host, '10.0.2.2', '127.0.0.1', 'localhost'];
    return candidates.toSet().toList();
  }

  static bool get isLocalLike {
    final value = host.toLowerCase();
    return value == 'localhost' || value == '127.0.0.1' || value == '10.0.2.2';
  }

  static String get connectionLabel =>
      isLocalLike ? 'Koneksi lokal' : 'Koneksi LAN';
}
