import 'package:expense/models/archive_params.dart';
import 'package:expense/models/category.dart';
import 'package:expense/models/metadata.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/metadata_types.dart';
import 'package:expense/models/sql_tables/archived_table.dart';
import 'package:expense/models/sql_tables/category_table.dart';
import 'package:expense/models/sql_tables/expenses_table.dart';
import 'package:expense/models/sql_tables/metadata_table.dart';
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
  late ExpensesTable _expensesTable;
  late CategoryTable _categoryTable;
  late ArchivedTable _archivedTable;
  late MetadataTable _metadataTable;
  late List<String> _tableNamesInOrderOfImportExecution;

  @override
  Future<void> init({int daysToKeepRecord = -1}) async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), 'expenses_database.db'),
      onCreate: (db, version) async {
        _instatiateTables(db);

        await _categoryTable.create(prepopulate: true);
        await _expensesTable.create();
        await _archivedTable.create();
        await _metadataTable.create();
        // await createUpiCategoryTable(db: db);
      },
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      version: 1,
    );
    dbInstance = db;
    _instatiateTables(dbInstance);

    _prefs = await SharedPreferences.getInstance();
    _importExportService = ImportExportService(
        db: dbInstance,
        tableNamesInOrderOfImportExecution:
            _tableNamesInOrderOfImportExecution);
  }

  void _instatiateTables(Database db) {
    _expensesTable = ExpensesTable(db);
    _categoryTable = CategoryTable(db);
    _archivedTable = ArchivedTable(db);
    _metadataTable = MetadataTable(db);
    _tableNamesInOrderOfImportExecution = [
      _categoryTable.tableName,
      _expensesTable.tableName,
      _archivedTable.tableName,
      _metadataTable.tableName
    ];
  }

  Future<bool> tableExists({required String tableName}) async {
    var res = await dbInstance
        .query('sqlite_master', where: 'name = ?', whereArgs: [tableName]);
    return res.isNotEmpty;
  }

  // Future<void> createUpiCategoryTable({required Database db}) async {
  //   debugPrint("EXECUTING CREATE UPI CAT TABLE");
  //   await db.execute(
  //       "CREATE TABLE ${SQLTableNames.UPI_CATEGORY_TABLE} ${UPICategory.getSQLCreateDatatypes()}");
  // }

  // Future<void> createHistoryTable({required Database db}) async {
  //   debugPrint("EXECUTING CREATE HISTORY CATEGORY TABLE");
  //   await db.execute(
  //       "CREATE TABLE ${SQLTableNames.CATEGORY_HISTORY_TABLE} ${CategoryHistory.getSQLCreateDatatypes()}");
  // }

  @override
  Future<void> addCategory(Category category) async =>
      await _categoryTable.add(category);

  @override
  Future<void> addExpense(Expense expense, Category category) async {
    await _expensesTable.add(expense);
    await _categoryTable.update(
        category: Category(
            id: category.id,
            name: category.name,
            totalExpense: category.totalExpense + expense.amount),
        where: category.getPrimaryKeySearchCondition());
  }

  @override
  Future<void> clearStorage({bool shouldInitCategory = true}) async {
    await _expensesTable.dropTable();
    await _categoryTable.dropTable();
    await _archivedTable.dropTable();
    await _metadataTable.dropTable();
    // await dbInstance.execute(
    //   'DROP TABLE ${SQLTableNames.UPI_CATEGORY_TABLE}',
    // );
    await _categoryTable.create(prepopulate: shouldInitCategory);
    await _expensesTable.create();
    await _archivedTable.create();
    await _metadataTable.create();
    // await createUpiCategoryTable(db: dbInstance);
  }

  @override
  Future<void> editExpense(
      {required Expense oldExpense,
      required Expense newExpense,
      required Category oldCategory,
      required Category newCategory}) async {
    await _expensesTable.update(newExpense);
    if (oldCategory.id == newCategory.id) {
      await _categoryTable.update(
          category: Category.increaseAmountBy(
              oldCategory, newExpense.amount - oldExpense.amount),
          where: oldCategory.getPrimaryKeySearchCondition());
      return;
    }
    //Reduce total amount in old Category by old Expense amount
    await _categoryTable.update(
        category: Category.reduceAmountBy(oldCategory, oldExpense.amount),
        where: oldCategory.getPrimaryKeySearchCondition());

    //Increase total amount in new Category by new Expense amount
    await _categoryTable.update(
        category: Category.increaseAmountBy(newCategory, newExpense.amount),
        where: newCategory.getPrimaryKeySearchCondition());
  }

  @override
  Future<Expense?> getLatestExpense() async => await _expensesTable.getLatest();

  @override
  Future<List<Expense>> getAllExpenses() async => await _expensesTable.getAll();

  @override
  Future<void> removeExpense(Expense expense, Category category) async {
    await _expensesTable.remove(expense);
    await _categoryTable.update(
        category: Category.reduceAmountBy(category, expense.amount),
        where: category.getPrimaryKeySearchCondition());
  }

  @override
  Future<CategoryEncapsulator> getCategoryEncapsulator() async {
    Set<Category> categorySet = await _categoryTable.getAll();
    List<Metadata> metadataList =
        await _metadataTable.getAll(MetadataType.CATEGORY_DATA);
    return CategoryEncapsulator(
        categories: categorySet,
        defaultCategory: categorySet.first,
        metadataList: metadataList);
  }

  @override
  Future<void> removeCategory(Category category) async {
    await _categoryTable.remove(category);
    await _metadataTable.removeMetadataOfTypeAndTypeId(
        type: MetadataType.CATEGORY_DATA, typeId: category.id);
  }

  @override
  Future<void> exportData({required BuildContext context}) async =>
      await _importExportService.exportData(context);

  @override
  Future<void> importData({required BuildContext context}) async =>
      await _importExportService.importData(context, clearStorage);

  // @override
  // Future<void> addUpiCategory(UPICategory upiCategory) async {
  //   debugPrint("EXECUTING SQL ADD UPI CAT");
  //   await dbInstance.insert(
  //       SQLTableNames.UPI_CATEGORY_TABLE, upiCategory.toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  // }

  // @override
  // Future<void> updateUpiCategory(UPICategory upiCategory) async {
  //   debugPrint("EXECUTING SQL UPDATE UPI CAT");
  //   await dbInstance.update(
  //       SQLTableNames.UPI_CATEGORY_TABLE, upiCategory.toMap(),
  //       where: upiCategory.getPrimaryKeySearchCondition());
  // }

  // @override
  // Future<UPICategory?> getUpiCategory({required String upiId}) async {
  //   UPICategory upiCategory = UPICategory(upiId: upiId, categoryId: "");
  //   var res = await dbInstance.query(SQLTableNames.UPI_CATEGORY_TABLE,
  //       where: upiCategory.getPrimaryKeySearchCondition());
  //   if (res.isEmpty) return null;
  //   return UPICategory.fromJson(res.first);
  // }

  @override
  Future<void> archiveAllExpenses() async {
    //TRANSFER ALL EXPENSES TO ARCHIVED TABLE
    await _archivedTable.saveAllCurrentExpenses(SQLTableNames.EXPENSES_TABLE);
    await _expensesTable.dropTable();
    await _expensesTable.create();

    //SET ALL CATEGORY TOTALS TO ZERO
    await _categoryTable.setTotalExpenseOfAllCategoriesToZero();
  }

  @override
  Future<void> archiveExpense({required Expense expense}) async =>
      await _archivedTable.add(expense);

  @override
  Future<List<Expense>> getAllArchivedExpensesOfCategory(
          {required Category category}) async =>
      await _archivedTable.getAllExpensesOfCategory(category);

  @override
  Future<void> unArchiveExpense({required Expense expense}) async =>
      await _archivedTable.remove(expense);

  @override
  Future<void> saveArchiveParams({required ArchiveParams archiveParams}) async {
    await _prefs.setString(
        ArchiveParams.sharedPrefKey, ArchiveParams.encode(archiveParams));
  }

  @override
  ArchiveParams? getArchiveParams() {
    String? res = _prefs.getString(ArchiveParams.sharedPrefKey);
    ArchiveParams? archiveParams;
    if (res != null) {
      archiveParams = ArchiveParams.decode(res);
    }
    return archiveParams;
  }

  @override
  Future<List<Expense>> getAllArchivedExpensesOnDate(
          {required DateTime datetime}) async =>
      await _archivedTable.getAllExpensesOnDate(datetime);

  @override
  Future<List<Expense>> getAllExpensesOnDate(
          {required DateTime datetime}) async =>
      await _expensesTable.getAllExpensesOnDate(datetime);

  @override
  Future<void> saveMetadata({required List<Metadata> metadataList}) async =>
      await _metadataTable.saveAll(metadataList);
}
