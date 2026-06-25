import '../../core/helpers/value_parser.dart';

class FamilyModel {
  const FamilyModel({
    required this.id,
    required this.familyName,
    this.familyCode,
    this.city,
    this.province,
    this.phone,
  });

  final int id;
  final String familyName;
  final String? familyCode;
  final String? city;
  final String? province;
  final String? phone;

  factory FamilyModel.fromRow(Map<String, dynamic> row) {
    return FamilyModel(
      id: ValueParser.asInt(row['id']),
      familyName: ValueParser.asString(row['family_name']),
      familyCode: row['family_code']?.toString(),
      city: row['city']?.toString(),
      province: row['province']?.toString(),
      phone: row['phone']?.toString(),
    );
  }
}
