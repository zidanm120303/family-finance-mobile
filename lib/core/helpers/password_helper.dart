import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';

class PasswordHelper {
  PasswordHelper._();

  static String hash(String password) =>
      BCrypt.hashpw(password, BCrypt.gensalt());

  static bool verify(String password, String storedHash) {
    if (storedHash.startsWith(r'$2a$') ||
        storedHash.startsWith(r'$2b$') ||
        storedHash.startsWith(r'$2y$')) {
      return BCrypt.checkpw(password, storedHash);
    }

    final sha = sha256.convert(utf8.encode(password)).toString();
    return sha == storedHash || password == storedHash;
  }
}
