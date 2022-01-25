import 'package:expense/models/archive_params.dart';
import 'package:expense/models/category.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/upi_category.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/sql_table_names.dart';
import 'package:expense/services/import_export_sql.dart';
import 'package:expense/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SQLStorage implements Storage {
  late Database dbInstance;
  late ImportExportService _importExportService;
  late SharedPreferences _prefs;

  @override
  Future<void> init({int daysToKeepRecord = -1}) async {
    debugPrint("EXECUTING SQL STORAGE INIT");
    Database db = await openDatabase(
      join(await getDatabasesPath(), 'expenses_database.db'),
      onCreate: (db, version) async {
        await createCategoryTable(db: db, shouldInit: true);
        await createExpensesTable(db: db);
        // await createUpiCategoryTable(db: db);
        await createArchivedTable(db: db);
      },
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      version: 1,
    );
    dbInstance = db;
    _prefs = await SharedPreferences.getInstance();
    _importExportService = ImportExportService(db: dbInstance);
  }

  Future<bool> tableExists({required String tableName}) async {
    var res = await dbInstance
        .query('sqlite_master', where: 'name = ?', whereArgs: [tableName]);
    return res.isNotEmpty;
  }

  Future<void> createExpensesTable({required Database db}) async {
    debugPrint("EXECUTING CREATE EXP");
    await db.execute(
        "CREATE TABLE ${SQLTableNames.EXPENSES_TABLE} ${Expense.getSQLCreateDatatypes()}");
  }

  Future<void> createCategoryTable(
      {required Database db, required bool shouldInit}) async {
    debugPrint("EXECUTING CREATE CAT");
    await db.execute(
        "CREATE TABLE ${SQLTableNames.CATEGORY_TABLE} ${Category.getSQLCreateDatatypes()}");
    if (shouldInit) {
      var _defaultCategories =
          CategoryEncapsulator.defaultValue().getCategoryList();
      for (var item in _defaultCategories) {
        await db.insert(SQLTableNames.CATEGORY_TABLE, item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<void> createUpiCategoryTable({required Database db}) async {
    debugPrint("EXECUTING CREATE UPI CAT TABLE");
    await db.execute(
        "CREATE TABLE ${SQLTableNames.UPI_CATEGORY_TABLE} ${UPICategory.getSQLCreateDatatypes()}");
  }

  Future<void> createArchivedTable({required Database db}) async {
    debugPrint("EXECUTING CREATE ARCHIVED TABLE");
    await db.execute(
        "CREATE TABLE ${SQLTableNames.ARCHIVED_TABLE} ${Expense.getSQLCreateDatatypes()}");
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
  Future<void> clearStorage({bool shouldInitCategory = true}) async {
    debugPrint("EXECUTING SQL CLEAR STORAGE");
    await dbInstance.execute(
      'DROP TABLE ${SQLTableNames.EXPENSES_TABLE}',
    );
    await dbInstance.execute(
      'DROP TABLE ${SQLTableNames.CATEGORY_TABLE}',
    );
    await dbInstance.execute(
      'DROP TABLE ${SQLTableNames.ARCHIVED_TABLE}',
    );
    // await dbInstance.execute(
    //   'DROP TABLE ${SQLTableNames.UPI_CATEGORY_TABLE}',
    // );
    await createCategoryTable(db: dbInstance, shouldInit: shouldInitCategory);
    await createExpensesTable(db: dbInstance);
    await createArchivedTable(db: dbInstance);
    // await createUpiCategoryTable(db: dbInstance);
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
    await _importExportService.importData(context, clearStorage);
  }

  @override
  Future<void> addUpiCategory(UPICategory upiCategory) async {
    debugPrint("EXECUTING SQL ADD UPI CAT");
    await dbInstance.insert(
        SQLTableNames.UPI_CATEGORY_TABLE, upiCategory.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateUpiCategory(UPICategory upiCategory) async {
    debugPrint("EXECUTING SQL UPDATE UPI CAT");
    await dbInstance.update(
        SQLTableNames.UPI_CATEGORY_TABLE, upiCategory.toMap(),
        where: upiCategory.getPrimaryKeySearchCondition());
  }

  @override
  Future<UPICategory?> getUpiCategory({required String upiId}) async {
    UPICategory upiCategory = UPICategory(upiId: upiId, categoryId: "");
    var res = await dbInstance.query(SQLTableNames.UPI_CATEGORY_TABLE,
        where: upiCategory.getPrimaryKeySearchCondition());
    if (res.isEmpty) return null;
    return UPICategory.fromJson(res.first);
  }

  @override
  Future<void> archiveAllExpenses() async {
    debugPrint("EXECUTING ARCHIVE ALL EXPENSES");
    //TRANSFER ALL EXPENSES TO ARCHIVED TABLE
    await dbInstance.execute(
        "INSERT INTO ${SQLTableNames.ARCHIVED_TABLE} SELECT * FROM ${SQLTableNames.EXPENSES_TABLE}");
    await dbInstance.execute(
      'DROP TABLE ${SQLTableNames.EXPENSES_TABLE}',
    );
    await createExpensesTable(db: dbInstance);
    //SET ALL CATEGORY TOTALS TO ZERO
    await dbInstance
        .execute("UPDATE ${SQLTableNames.CATEGORY_TABLE} SET totalExpense=0");
  }

  @override
  Future<void> archiveExpense({required Expense expense}) async {
    //TRANSFER EXPENSE TO ARCHIVED TABLE
    debugPrint("EXECUTING ARCHIVE EXPENSE");
    await dbInstance.insert(SQLTableNames.ARCHIVED_TABLE, expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<Expense>> getAllArchivedExpensesOfCategory(
      {required Category category}) async {
    debugPrint("EXECUTING GET ALL ARCHIVE EXPENSE");
    var res = await dbInstance.query(SQLTableNames.ARCHIVED_TABLE,
        where: category.getSearchConditionForExpense());
    List<Expense> expenses = [];
    for (var element in res) {
      expenses.add(Expense.fromJson(element));
    }
    return expenses;
  }

  @override
  Future<void> unArchiveExpense(
      {required Expense expense, required Category category}) async {
    debugPrint("EXECUTING UNARCHIVE EXPENSE");
    await dbInstance.delete(SQLTableNames.ARCHIVED_TABLE,
        where: expense.getPrimaryKeySearchCondition());
  }

  @override
  Future<void> saveArchiveParams({required ArchiveParams archiveParams}) async {
    debugPrint("EXECUTING SAVE ARCHIVE PARAMS");
    await _prefs.setString(
        ArchiveParams.sharedPrefKey, ArchiveParams.encode(archiveParams));
  }

  @override
  ArchiveParams? getArchiveParams() {
    debugPrint("EXECUTING GET ARCHIVE EXPENSE");
    String? res = _prefs.getString(ArchiveParams.sharedPrefKey);
    ArchiveParams? archiveParams;
    if (res != null) {
      archiveParams = ArchiveParams.decode(res);
    }
    return archiveParams;
  }

  @override
  Future<List<Expense>> getAllArchivedExpensesOnDate(
      {required DateTime datetime}) async {
    debugPrint("EXECUTING GET ALL ARCHIVE ON DATE");
    List<Expense> expenses = [];
    var from = DateTime(datetime.year, datetime.month, datetime.day);
    var to = DateTime(datetime.year, datetime.month, datetime.day + 1);
    var res = await dbInstance.query(SQLTableNames.ARCHIVED_TABLE,
        where: "time BETWEEN ? AND ?",
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch]);
    for (var element in res) {
      expenses.add(Expense.fromJson(element));
    }
    return expenses;
  }

  @override
  Future<List<Expense>> getAllExpensesOnDate(
      {required DateTime datetime}) async {
    debugPrint("EXECUTING GET ALL EXPENSES ON DATE");
    List<Expense> expenses = [];
    var from = DateTime(datetime.year, datetime.month, datetime.day);
    var to = DateTime(datetime.year, datetime.month, datetime.day + 1);
    var res = await dbInstance.query(SQLTableNames.EXPENSES_TABLE,
        where: "time BETWEEN ? AND ?",
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch]);
    for (var element in res) {
      expenses.add(Expense.fromJson(element));
    }
    return expenses;
  }
}
