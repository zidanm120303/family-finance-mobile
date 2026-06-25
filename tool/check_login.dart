// ignore_for_file: avoid_print

import 'package:famfinance_mobile/data/repositories/auth_repository.dart';

Future<void> main() async {
  final repo = AuthRepository();
  final user = await repo.login(
    identity: 'budi.pratama@email.com',
    password: 'password',
  );
  print('Login OK: ${user.name} - ${user.familyName}');
}
