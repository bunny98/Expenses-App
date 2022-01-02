import 'package:expense/models/category.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/sql_table_names.dart';
import 'package:expense/services/import_export_sql.dart';
import 'package:expense/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SQLStorage implements Storage {
  late Database dbInstance;
  late ImportExportService _importExportService;

  @override
  Future<void> init({int daysToKeepRecord = -1}) async {
    debugPrint("EXECUTING SQL STORAGE INIT");
    Database db = await openDatabase(
      join(await getDatabasesPath(), 'expenses_database.db'),
      onCreate: (db, version) async {
        await createCategoryTable(db: db);
        await createExpensesTable(db: db);
      },
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      version: 1,
    );
    dbInstance = db;
    _importExportService = ImportExportService(db: dbInstance);
  }

  Future<void> createExpensesTable({required Database db}) async {
    debugPrint("EXECUTING CREATE EXP");
    await db.execute(
        "CREATE TABLE ${SQLTableNames.EXPENSES_TABLE} ${Expense.getSQLCreateDatatypes()}");
  }

  Future<void> createCategoryTable({required Database db}) async {
    debugPrint("EXECUTING CREAT CAT");
    await db.execute(
        "CREATE TABLE ${SQLTableNames.CATEGORY_TABLE} ${Category.getSQLCreateDatatypes()}");
    var _defaultCategories =
        CategoryEncapsulator.defaultValue().getCategoryList();
    for (var item in _defaultCategories) {
      await db.insert(SQLTableNames.CATEGORY_TABLE, item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    debugPrint("EXECUTING SQL ADD CAT");
    await dbInstance.insert(SQLTableNames.CATEGORY_TABLE, category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> addExpense(Expense expense, Category category) async {
    debugPrint("EXECUTING SQL ADD EXP");
    await dbInstance.insert(SQLTableNames.EXPENSES_TABLE, expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await dbInstance.update(
        SQLTableNames.CATEGORY_TABLE,
        Category(
                id: category.id,
                name: category.name,
                totalExpense: category.totalExpense + expense.amount)
            .toMap(),
        where: category.getPrimaryKeySearchCondition());
  }

  @override
  Future<void> clearStorage() async {
    debugPrint("EXECUTING SQL CLEAR STORAGE");
    await dbInstance.execute(
      'DROP TABLE ${SQLTableNames.EXPENSES_TABLE}',
    );
    await dbInstance.execute(
      'DROP TABLE ${SQLTableNames.CATEGORY_TABLE}',
    );
    await createCategoryTable(db: dbInstance);
    await createExpensesTable(db: dbInstance);
  }

  @override
  Future<void> editExpense(
      {required Expense oldExpense,
      required Expense newExpense,
      required Category oldCategory,
      required Category newCategory}) async {
    debugPrint("EXECUTING SQL EDIT EXP");
    await dbInstance.update(SQLTableNames.EXPENSES_TABLE, newExpense.toMap(),
        where: newExpense.getPrimaryKeySearchCondition());
    if (oldCategory.id == newCategory.id) {
      await dbInstance.update(
          SQLTableNames.CATEGORY_TABLE,
          Category.increaseAmountBy(
                  oldCategory, newExpense.amount - oldExpense.amount)
              .toMap(),
          where: oldCategory.getPrimaryKeySearchCondition());
      return;
    }
    //Reduce total amount in old Category by old Expense amount
    await dbInstance.update(SQLTableNames.CATEGORY_TABLE,
        Category.reduceAmountBy(oldCategory, oldExpense.amount).toMap(),
        where: oldCategory.getPrimaryKeySearchCondition());
    //Increase total amount in new Category by new Expense amount
    await dbInstance.update(SQLTableNames.CATEGORY_TABLE,
        Category.increaseAmountBy(newCategory, newExpense.amount).toMap(),
        where: newCategory.getPrimaryKeySearchCondition());
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    debugPrint("EXECUTING SQL GETALL EXP");
    List<Map<String, dynamic>> res =
        await dbInstance.query(SQLTableNames.EXPENSES_TABLE);
    List<Expense> expenses = [];
    for (var item in res) {
      expenses.add(Expense.fromJson(item));
    }
    return expenses;
  }

  @override
  Future<void> removeExpense(Expense expense, Category category) async {
    debugPrint("EXECUTING SQL REM EXP");
    await dbInstance.delete(SQLTableNames.EXPENSES_TABLE,
        where: expense.getPrimaryKeySearchCondition());
    await dbInstance.update(SQLTableNames.CATEGORY_TABLE,
        Category.reduceAmountBy(category, expense.amount).toMap(),
        where: category.getPrimaryKeySearchCondition());
  }

  @override
  Future<CategoryEncapsulator> getCategoryEncapsulator() async {
    debugPrint("EXECUTING SQL GET CAT ENCAP");
    List<Map<String, dynamic>> res =
        await dbInstance.query(SQLTableNames.CATEGORY_TABLE);
    Set<Category> _categories = {};
    for (var item in res) {
      _categories.add(Category.fromJson(item));
    }
    return CategoryEncapsulator(
        categories: _categories, defaultCategory: _categories.first);
  }

  @override
  Future<void> removeCategory(Category category) async {
    debugPrint("EXECUTING SQL RMC CAT");
    await dbInstance.delete(SQLTableNames.CATEGORY_TABLE,
        where: category.getPrimaryKeySearchCondition());
  }

  @override
  Future<void> exportData({required BuildContext context}) async {
    await _importExportService.exportData(context);
  }

  @override
  Future<void> importData({required BuildContext context}) async {
    await _importExportService.importData(context);
  }
}
