import 'package:flutter/foundation.dart';

import '../../core/session/session_manager.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthRepository? authRepository,
    SessionManager? sessionManager,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _sessionManager = sessionManager ?? SessionManager.instance;

  final AuthRepository _authRepository;
  final SessionManager _sessionManager;

  bool isLoading = false;
  SessionData? session;
  String? errorMessage;

  bool get isLoggedIn => session != null;

  Future<void> checkSession() async {
    isLoading = true;
    notifyListeners();
    session = await _sessionManager.load();
    isLoading = false;
    notifyListeners();
  }

  Future<bool> login({
    required String identity,
    required String password,
  }) async {
    return _guard(() async {
      final user = await _authRepository.login(
        identity: identity,
        password: password,
      );
      await _sessionManager.saveUser(user);
      session = await _sessionManager.load();
      return true;
    });
  }

  Future<bool> register(RegisterRequest request) async {
    return _guard(() async {
      final user = await _authRepository.register(request);
      await _sessionManager.saveUser(user);
      session = await _sessionManager.load();
      return true;
    });
  }

  Future<void> logout() async {
    await _sessionManager.clear();
    session = null;
    notifyListeners();
  }

  Future<bool> _guard(Future<bool> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await action();
      return result;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
