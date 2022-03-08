import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

abstract class ITable {
  final Database db;
  final String tableName;
  ITable(this.db, this.tableName);

  Future<void> create({bool prepopulate = false});
  Future<void> dropTable() async {
    debugPrint("DROPPING TABLE $tableName");
    await db.execute(
      'DROP TABLE $tableName',
    );
  }
}
