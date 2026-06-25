import 'package:flutter/material.dart';

import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/shell/main_shell_page.dart';
import '../features/splash/splash_page.dart';
import '../features/transaction/transaction_detail_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const shell = '/home';
  static const transactionDetail = '/transaction-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        switch (settings.name) {
          case splash:
            return const SplashPage();
          case login:
            return const LoginPage();
          case register:
            return const RegisterPage();
          case shell:
            return const MainShellPage();
          case transactionDetail:
            final id = settings.arguments as int;
            return TransactionDetailPage(transactionId: id);
          default:
            return const SplashPage();
        }
      },
    );
  }
}
