import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/value_parser.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.familyId,
    required this.categoryName,
    required this.type,
    this.icon,
    this.color,
  });

  final int id;
  final int familyId;
  final String categoryName;
  final String type;
  final String? icon;
  final String? color;

  bool get isIncome => type == 'income';

  Color get displayColor {
    final value = color?.replaceAll('#', '');
    if (value == null || value.length != 6) {
      return isIncome ? AppColors.primaryGreen : AppColors.danger;
    }
    return Color(int.parse('FF$value', radix: 16));
  }

  factory CategoryModel.fromRow(Map<String, dynamic> row) {
    return CategoryModel(
      id: ValueParser.asInt(row['id']),
      familyId: ValueParser.asInt(row['family_id']),
      categoryName: ValueParser.asString(row['category_name']),
      type: ValueParser.asString(row['type']),
      icon: row['icon']?.toString(),
      color: row['color']?.toString(),
    );
  }
}
