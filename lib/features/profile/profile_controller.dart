import 'package:flutter/foundation.dart';

import '../../core/session/session_manager.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({SessionManager? sessionManager})
    : _sessionManager = sessionManager ?? SessionManager.instance;

  final SessionManager _sessionManager;

  SessionData? session;

  Future<void> load() async {
    session = await _sessionManager.load();
    notifyListeners();
  }
}
