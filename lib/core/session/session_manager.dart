import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';

class SessionData {
  const SessionData({
    required this.userId,
    required this.familyId,
    required this.name,
    required this.email,
    required this.roleName,
    required this.familyName,
    this.username,
    this.phone,
  });

  final int userId;
  final int familyId;
  final String name;
  final String email;
  final String roleName;
  final String familyName;
  final String? username;
  final String? phone;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'FF';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  static const _userId = 'user_id';
  static const _familyId = 'family_id';
  static const _name = 'name';
  static const _email = 'email';
  static const _roleName = 'role_name';
  static const _familyName = 'family_name';
  static const _username = 'username';
  static const _phone = 'phone';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userId, user.id);
    await prefs.setInt(_familyId, user.familyId ?? 0);
    await prefs.setString(_name, user.name);
    await prefs.setString(_email, user.email);
    await prefs.setString(_roleName, user.roleName ?? '');
    await prefs.setString(_familyName, user.familyName ?? '');
    await prefs.setString(_username, user.username ?? '');
    await prefs.setString(_phone, user.phone ?? '');
  }

  Future<SessionData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userId);
    final familyId = prefs.getInt(_familyId);
    if (userId == null || familyId == null || userId <= 0 || familyId <= 0) {
      return null;
    }
    return SessionData(
      userId: userId,
      familyId: familyId,
      name: prefs.getString(_name) ?? '',
      email: prefs.getString(_email) ?? '',
      roleName: prefs.getString(_roleName) ?? '',
      familyName: prefs.getString(_familyName) ?? '',
      username: prefs.getString(_username),
      phone: prefs.getString(_phone),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userId);
    await prefs.remove(_familyId);
    await prefs.remove(_name);
    await prefs.remove(_email);
    await prefs.remove(_roleName);
    await prefs.remove(_familyName);
    await prefs.remove(_username);
    await prefs.remove(_phone);
  }
}
