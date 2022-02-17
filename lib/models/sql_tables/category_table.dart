import 'package:expense/models/sql_table_names.dart';
import 'package:expense/models/sql_tables/itable.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../category.dart';

class CategoryTable extends ITable {
  CategoryTable(Database db) : super(db, SQLTableNames.CATEGORY_TABLE);

  @override
  Future<void> create({bool prepopulate = false}) async {
    debugPrint("EXECUTING CREATE CAT");
    await db.execute(
        "CREATE TABLE ${SQLTableNames.CATEGORY_TABLE} ${Category.getSQLCreateDatatypes()}");
    if (prepopulate) {
      var _defaultCategories =
          CategoryEncapsulator.defaultValue().getCategoryList();
      for (var item in _defaultCategories) {
        await db.insert(SQLTableNames.CATEGORY_TABLE, item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<void> add(Category category) async {
    await db.insert(tableName, category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(
      {required Category category, required String where}) async {
    await db.update(tableName, category.toMap(), where: where);
  }

  Future<void> remove(Category category) async {
    await db.delete(tableName, where: category.getPrimaryKeySearchCondition());
  }

  Future<void> setTotalExpenseOfAllCategoriesToZero() async {
    await db
        .execute("UPDATE $tableName SET ${Category.getTotalExpenseName()}=0");
  }

  Future<CategoryEncapsulator> getCategoryEncapsulator() async {
    List<Map<String, dynamic>> res = await db.query(tableName);
    Set<Category> _categories = {};
    for (var item in res) {
      _categories.add(Category.fromJson(item));
    }
    return CategoryEncapsulator(
        categories: _categories, defaultCategory: _categories.first);
  }
}
