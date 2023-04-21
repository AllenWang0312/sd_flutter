import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sd/sd/tavern/bean/FileInfo.dart';
import 'package:sd/sd/bean/db/Workspace.dart';
import 'package:sqflite/sqflite.dart';

import 'tavern/bean/UniqueSign.dart';
import 'bean/db/History.dart';
import 'bean/db/PromptStyleFileConfig.dart';
import 'http_service.dart';

String dbString(String string) {
  return string.replaceAll(":", "_");
}

class DBController {
  final String TAG = "DBController";
  static final DBController _instance = DBController._internal();

  static DBController get instance {
    return _instance;
  }

  DBController._internal();

  String workspace = '';
  Database? database;

  Future initDepends({String? workspace}) async {
    if (null != workspace) {
      this.workspace = workspace;
      if (null == database || !database!.isOpen) {
        var databasePath = await getDatabasesPath();
        // String ext = workspace.isEmpty ? '' : '_$workspace';
        var dbpath = join(databasePath, 'ai_paint.db');
        database = await openDatabase(dbpath,
            version: 3,
            onCreate: (Database db, int version) async {
              logt(TAG, "db create");
              await db.execute(
                  'CREATE TABLE ${Workspace.TABLE_NAME} (${Workspace.TABLE_CREATE})');
              await db.execute(
                  'CREATE TABLE ${PromptStyleFileConfig.TABLE_NAME} (${PromptStyleFileConfig.TABLE_CREATE})');
              await db.execute(
                  'CREATE TABLE ${History.TABLE_NAME} (${History.TABLE_CREATE})');
              await db.execute(
                  'CREATE TABLE ${FileInfo.TABLE_NAME} (${FileInfo.TABLE_CREATE})');

              // await db.execute(
              //     'CREATE TABLE ${PromptStyle.TABLE_NAME} (${PromptStyle.TABLE_CREATE})');
            },
            onUpgrade: (Database db, int oldVersion, int newVersion) async {
              await db.execute(
                  'CREATE TABLE ${FileInfo.TABLE_NAME} (${FileInfo.TABLE_CREATE})');


            },
            onDowngrade: (Database db, int oldVersion, int newVersion) async {
              // logt(TAG,"db downgrade $oldVersion to $newVersion");
              //
              // for (int i = oldVersion; i > newVersion; i--) {
              //   if (i == 1) {
              //     await db.execute('DELETE TABLE ${History.TABLE_NAME}');
              //   } else if (i == 2) {
              //     await db.execute('DELETE TABLE ${Workspace.TABLE_NAME}');
              //   } else if (i == 3) {
              //     await db.execute('DELETE TABLE prompt_styles');
              //   }
              // }
            });
      }
      var wss = await queryWorkspace(workspace);
      if (wss?.length == 1) {
        logt(TAG, wss![0].toString());
        return Workspace.fromJson(wss![0]);
      }
    }
    return Future.value(null);
  }

  isTableExits(String tableName) async {
    var sql =
        "SELECT * FROM sqlite_master WHERE TYPE = 'table' AND NAME = '$tableName'";
    var res = await database?.rawQuery(sql);
    return res != null && res.length > 0;
  }

  Future<void> dispose() async {
    await database?.close();
  }

  Future<int> insertHistory(History history) {
    // String ext = null != workspace && workspace.isNotEmpty ? '_$workspace' : '';

    if (null != database && database!.isOpen) {
      return Future.value(
          database?.insert(History.TABLE_NAME, history.toJson()));
    }
    return Future.error('insert error');
  }
  Future<int> insertAgeLevelRecord(UniqueSign info,Uint8List? data,int ageLevel) async {
    // String ext = null != workspace && workspace.isNotEmpty ? '_$workspace' : '';

    if (null != database && database!.isOpen) {
      return Future.value(
          database?.insert(FileInfo.TABLE_NAME,toDynamic(info.getSign(data),ageLevel)));
    }
    return Future.error('insert error');
  }

  Future<int> updateAgeLevelRecord(UniqueSign info,Uint8List? data,int ageLevel) async {
    // String ext = null != workspace && workspace.isNotEmpty ? '_$workspace' : '';

    if (null != database && database!.isOpen) {
      return Future.value(
          database?.update(FileInfo.TABLE_NAME,toDynamic(info.getSign(data),ageLevel),where: "sign = ? ",whereArgs: [info.getSign(data)]));
    }
    return Future.error('insert error');
  }
  Future<int> removetAgeLevelRecord(UniqueSign info,Uint8List? data) async {
    if (null != database && database!.isOpen) {
      return database!.delete(FileInfo.TABLE_NAME,
          where: "sign = ?",
          whereArgs: [info.getSign(data)]);
    }
    return Future.value(-1);
  }

  Future<List<dynamic>>? queryAgeLevelRecord() {
    return database?.rawQuery(
        'SELECT * FROM ${FileInfo.TABLE_NAME} ORDER BY ageLevel DESC');
  }

  Future<int> insertWorkSpace(Workspace workspace) {
    if (null != database && database!.isOpen) {
      return database!.insert(Workspace.TABLE_NAME, workspace.toJson());
    }
    return Future.value(-1);
  }

  Future<int> insertStyleFileConfig(PromptStyleFileConfig config) {
    if (null != database && database!.isOpen) {
      return database!
          .insert(PromptStyleFileConfig.TABLE_NAME, config.toJson());
    }
    return Future.value(-1);
  }

  Future<int> removeStyleFileConfigWith(int belongTo, String configPath) {
    if (null != database && database!.isOpen) {
      return database!.delete(PromptStyleFileConfig.TABLE_NAME,
          where: "belongTo = ? AND configPath = ?",
          whereArgs: [belongTo, configPath]);
    }
    return Future.value(-1);
  }

  Future<int> removeStyleFileConfig(int id) {
    if (null != database && database!.isOpen) {
      return database!.delete(PromptStyleFileConfig.TABLE_NAME,
          where: "id = ?", whereArgs: [id]);
    }
    return Future.value(-1);
  }

  Future<List<dynamic>>? queryHistorys(int pageNum, int pageSize,
      {String? order, bool asc = true}) {
    return database?.rawQuery(
        'SELECT * FROM ${History.TABLE_NAME} order by $order ${asc ? "asc" : "desc"} limit $pageNum ,$pageSize');
  }

  Future<List<dynamic>>? queryWorkspaces() {
    return database?.rawQuery('SELECT * FROM ${Workspace.TABLE_NAME}');
  }

  Future<List<dynamic>>? queryWorkspace(String name) {
    return database?.rawQuery(
        "SELECT * FROM ${Workspace.TABLE_NAME} WHERE name = ? ", [name]);
  }

  Future<List<dynamic>>? getStyleFileConfigs() {
    return database
        ?.rawQuery("SELECT * FROM ${PromptStyleFileConfig.TABLE_NAME}");
  }

  Future<List<dynamic>>? queryStyles(int wsId) {
    return database?.rawQuery(
        "SELECT * FROM ${PromptStyleFileConfig.TABLE_NAME} WHERE belongTo = ? ",
        [wsId]);
  }
}
