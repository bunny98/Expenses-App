import 'package:expense/models/category.dart';
import 'package:expense/models/metadata_types.dart';
import 'package:expense/models/sql_table_names.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../metadata.dart';
import 'itable.dart';

class MetadataTable extends ITable {
  MetadataTable(Database db) : super(db, SQLTableNames.METADATA_TABLE);

  @override
  Future<void> create({bool prepopulate = false}) async {
    debugPrint("EXECUTING CREATE METADATA");
    await db
        .execute("CREATE TABLE $tableName ${Metadata.getSQLCreateDatatypes()}");
  }

  Future<void> saveAll(List<Metadata> metadataList) async {
    Batch batch = db.batch();
    for (var element in metadataList) {
      batch.insert(tableName, element.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Metadata>> getAll(String type) async {
    return (await db.query(tableName,
            where: Metadata.getTypeSearchCondition(type)))
        .map((e) => Metadata.fromJson(e))
        .toList();
  }

  Future<void> removeMetadataOfTypeAndTypeId(
      {required String type, required String typeId}) async {
    await db.delete(tableName,
        where: Metadata.getTypeAndTypeIdSearchCondition(
            type: type, typeId: typeId));
  }
}
