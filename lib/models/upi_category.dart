import 'dart:convert';

import 'package:expense/models/sql_table_names.dart';

import 'category.dart';

class UPICategory {
  final String upiId;
  final String categoryId;

  UPICategory({required this.upiId, required this.categoryId});

  factory UPICategory.fromJson(Map<String, dynamic> jsonData) {
    return UPICategory(
      upiId: jsonData['upiId'],
      categoryId: jsonData['categoryId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'upiId': upiId,
        'categoryId': categoryId,
      };

  String getPrimaryKeySearchCondition() => "upiId = \"$upiId\"";
  static String encode(UPICategory upiCategory) =>
      json.encode(upiCategory.toMap());
  static UPICategory decode(String upiCategory) =>
      UPICategory.fromJson(json.decode(upiCategory));

  static String getSQLCreateDatatypes() =>
      "(upiId TEXT PRIMARY KEY, categoryId TEXT NOT NULL, FOREIGN KEY (categoryId) REFERENCES ${SQLTableNames.CATEGORY_TABLE} (${Category.getPrimaryKeyName()}) ON DELETE CASCADE)";
}
