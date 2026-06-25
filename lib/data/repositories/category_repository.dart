import '../../core/database/mysql_database_service.dart';
import '../../core/database/sql_queries.dart';
import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository({MysqlDatabaseService? database})
    : _database = database ?? MysqlDatabaseService.instance;

  final MysqlDatabaseService _database;

  Future<List<CategoryModel>> byType({
    required int familyId,
    required String type,
  }) {
    return _database.run((conn) async {
      final result = await conn.execute(SqlQueries.categoriesByType, {
        'family_id': familyId,
        'type': type,
      });
      return result.rows
          .map((row) => CategoryModel.fromRow(row.typedAssoc()))
          .toList();
    });
  }
}
