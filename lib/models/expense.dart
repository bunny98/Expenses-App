import 'dart:convert';

import 'package:expense/models/category.dart';
import 'package:expense/models/sql_table_names.dart';

class Expense {
  final String id;
  final String categoryId;
  final int amount;
  final String description;
  final String paymentType;
  final DateTime time;

  Expense(
      {required this.id,
      required this.amount,
      required this.description,
      required this.paymentType,
      required this.time,
      required this.categoryId});

  factory Expense.fromJson(Map<String, dynamic> jsonData) {
    return Expense(
      id: jsonData['id'],
      amount: jsonData['amount'],
      description: jsonData['description'],
      paymentType: jsonData['paymentType'],
      time: DateTime.fromMillisecondsSinceEpoch(jsonData['time']),
      categoryId: jsonData['categoryId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'description': description,
        'paymentType': paymentType,
        'time': time.millisecondsSinceEpoch,
        'categoryId': categoryId,
      };

  String getPrimaryKeySearchCondition() => "id = \"$id\"";
  static getTimeAttributeName() => "time";
  static String encode(Expense expense) => json.encode(expense.toMap());
  static Expense decode(String expense) =>
      Expense.fromJson(json.decode(expense));

  static String getSQLCreateDatatypes() =>
      "(id TEXT PRIMARY KEY, categoryId TEXT NOT NULL, amount INTEGER, description TEXT, paymentType TEXT, time INTEGER, FOREIGN KEY (categoryId) REFERENCES ${SQLTableNames.CATEGORY_TABLE} (${Category.getPrimaryKeyName()}) ON DELETE CASCADE)";
}
