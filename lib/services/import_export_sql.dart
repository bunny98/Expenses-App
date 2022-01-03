// ignore: file_names
import 'dart:io';

import 'package:expense/models/sql_table_names.dart';
import 'package:expense/utils/global_func.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_porter/sqflite_porter.dart';

class ImportExportService {
  final Database db;

  ImportExportService({
    required this.db,
  });

  Future<Directory> getRootDir() async {
    final String externalDirectory =
        (await getExternalStorageDirectory())!.path;
    var pathList = externalDirectory.split('/');
    String pathToStorage = "";
    String os = Platform.isAndroid ? "Android" : "iOS";
    for (var ele in pathList) {
      if (ele == os) break;
      pathToStorage += "$ele/";
    }
    return Directory(pathToStorage);
  }

  Future<void> exportData(BuildContext context) async {
    var export = await dbExportSql(db);
    // Share.share(export.toString(), subject: "DB STMTS");
    var strToExport = "";
    for (var item in export) {
      strToExport += item;
      if (export.last != item) strToExport += "\n";
    }
    if ((await Permission.storage.request()).isGranted) {
      // Directory? rootPath = await getExternalStorageDirectory();
      String? path = await FilesystemPicker.open(
          title: 'Save to folder',
          context: context,
          rootDirectory: await getRootDir(),
          fsType: FilesystemType.folder,
          pickText: 'Save file',
          folderIconColor: Colors.teal,
          fileTileSelectMode: FileTileSelectMode.wholeTile);
      debugPrint(path);
      if (path != null) {
        try {
          final file = File('${path}expenses-db-backup.txt');
          await file.writeAsString(strToExport);
          debugPrint(file.path);
          showToast("Database file saved at ${file.path}");
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }

  Future<void> importData(BuildContext context) async {
    if ((await Permission.storage.request()).isGranted) {
      String? path = await FilesystemPicker.open(
        title: 'Open file',
        context: context,
        rootDirectory: await getRootDir(),
        fsType: FilesystemType.file,
        folderIconColor: Colors.teal,
        allowedExtensions: ['.txt'],
        fileTileSelectMode: FileTileSelectMode.wholeTile,
      );
      if (path != null) {
        var file = File(path);
        try {
          String fileContents = await file.readAsString();
          var importedCommands = fileContents.split("\n");
          var currentCommands = await getCurrentInsertCommands();

          if (importedCommands.isNotEmpty) {
            await db.execute(
              'DROP TABLE ${SQLTableNames.EXPENSES_TABLE}',
            );
            await db.execute(
              'DROP TABLE ${SQLTableNames.CATEGORY_TABLE}',
            );
            await dbImportSql(db, importedCommands);
            await dbImportSql(db, currentCommands);
            showToast("Imported!");
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }

  Future<List<String>> getCurrentInsertCommands() async {
    var currentCommands = await dbExportSql(db);
    List<String> res = [];
    for (var item in currentCommands) {
      if (item.startsWith("INSERT INTO ${SQLTableNames.EXPENSES_TABLE}")) {
        res.add(item);
      }
    }
    return res;
  }
}
