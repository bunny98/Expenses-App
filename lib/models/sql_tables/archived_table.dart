import 'package:expense/models/expense.dart';
import 'package:expense/models/sql_tables/itable.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../category.dart';
import '../sql_table_names.dart';

class ArchivedTable extends ITable {
  ArchivedTable(Database db) : super(db, SQLTableNames.ARCHIVED_TABLE);

  @override
  Future<void> create({bool prepopulate = false}) async {
    debugPrint("EXECUTING CREATE ARC");
    await db
        .execute("CREATE TABLE $tableName ${Expense.getSQLCreateDatatypes()}");
  }

  Future<void> saveAllCurrentExpenses(String expensesTableName) async {
    await db.execute("INSERT INTO $tableName SELECT * FROM $expensesTableName");
  }

  Future<void> add(Expense expense) async {
    await db.insert(tableName, expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(Expense expense) async {
    await db.delete(tableName, where: expense.getPrimaryKeySearchCondition());
  }

  Future<List<Expense>> getAllExpensesOnDate(DateTime datetime) async {
    List<Expense> expenses = [];
    var from = DateTime(datetime.year, datetime.month, datetime.day);
    var to = DateTime(datetime.year, datetime.month, datetime.day + 1);
    var res = await db.query(tableName,
        where: "time BETWEEN ? AND ?",
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch]);
    for (var element in res) {
      expenses.add(Expense.fromJson(element));
    }
    return expenses;
  }

  Future<List<Expense>> getAllExpensesOfCategory(Category category) async {
    var res = await db.query(tableName,
        where: category.getSearchConditionForExpense());
    List<Expense> expenses = [];
    for (var element in res) {
      expenses.add(Expense.fromJson(element));
    }
    return expenses;
  }
}
