import 'package:expense/models/expense.dart';
import 'package:expense/models/sql_table_names.dart';
import 'package:expense/models/sql_tables/itable.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ExpensesTable extends ITable {
  ExpensesTable(Database db) : super(db, SQLTableNames.EXPENSES_TABLE);

  @override
  Future<void> create({bool prepopulate = false}) async {
    debugPrint("EXECUTING CREATE EXP");
    await db
        .execute("CREATE TABLE $tableName ${Expense.getSQLCreateDatatypes()}");
  }

  Future<void> add(Expense expense) async {
    await db.insert(tableName, expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Expense newExpense) async {
    await db.update(tableName, newExpense.toMap(),
        where: newExpense.getPrimaryKeySearchCondition());
  }

  Future<void> remove(Expense expense) async {
    await db.delete(tableName, where: expense.getPrimaryKeySearchCondition());
  }

  Future<List<Expense>> getAll() async {
    List<Map<String, dynamic>> res = await db.query(tableName);
    List<Expense> expenses = [];
    for (var item in res) {
      expenses.add(Expense.fromJson(item));
    }
    return expenses;
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
}
