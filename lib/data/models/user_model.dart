import '../../core/helpers/value_parser.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    this.familyId,
    this.roleId,
    this.username,
    this.phone,
    this.roleName,
    this.familyName,
  });

  final int id;
  final int? familyId;
  final int? roleId;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final bool isActive;
  final String? roleName;
  final String? familyName;

  factory UserModel.fromRow(Map<String, dynamic> row) {
    return UserModel(
      id: ValueParser.asInt(row['id']),
      familyId: ValueParser.asNullableInt(row['family_id']),
      roleId: ValueParser.asNullableInt(row['role_id']),
      name: ValueParser.asString(row['name']),
      email: ValueParser.asString(row['email']),
      username: row['username']?.toString(),
      phone: row['phone']?.toString(),
      isActive: ValueParser.asBool(row['is_active']),
      roleName: row['role_name']?.toString(),
      familyName: row['family_name']?.toString(),
    );
  }
}
