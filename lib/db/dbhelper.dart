import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:empty_wallet/db/Item.dart';
import 'package:empty_wallet/db/Item.dart' as prefix0;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Item.dart';

var database;
var dbName = "debt_database.db";

const CREATE_PLATFORM_TABLE = '''
    CREATE TABLE PlatformTable(
          id INTEGER PRIMARY KEY,
          platformName TEXT,
          dueDate TEXT,
          totalNum REAL
    )
      ''';
const CREATE_SUBPLATFORM_TABLE = '''
    CREATE TABLE SubPlatformTable(
          id INTEGER PRIMARY KEY,
          monthKey TEXT,
          platformKey TEXT,  
          numThisStage REAL, 
          isPaidOff INT
    )
    ''';
const CREATE_ITEM_TABLE = '''
    CREATE TABLE ItemTable(
          id INTEGER PRIMARY KEY,
          platformKey TEXT,
          itemName TEXT,
          stageNum INT,
          numPerStage REAL,
          paidStageNum INT
    )
''';
const CREATE_SUBITEM_TABLE = '''
    CREATE TABLE SubItemTable(
          id INTEGER PRIMARY KEY,
          itemKey TEXT,
          monthKey TEXT,
          numThisStage REAL,
          currentStage INT
    )
    ''';

//Many app have one database and would never need to close it, it will be closed when the app is terminated.
void openDB() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, dbName);
  // Make sure the directory exists
  try {
    await Directory(databasesPath).create(recursive: true);
  } catch (_) {}
  database = await openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(CREATE_PLATFORM_TABLE);
      db.execute(CREATE_SUBPLATFORM_TABLE);
      db.execute(CREATE_ITEM_TABLE);
      db.execute(CREATE_SUBITEM_TABLE);
    },
    version: 1,
  );
}

/*
* insert method*/
Future<int> insertDate(dynamic dn) async {
  final Database db = await database;
  return await db.insert(dn.runtimeType.toString() + 'Table', dn.toMap());
}

/*
* get method*/
Future<Platform> getPf(String name) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query('PlatformTable', where: 'platformName = ?', whereArgs: [name]);
  assert(maps.length < 2, 'map\' s length should not larger than 1');
  Map<String, dynamic> map = maps[0];
  var pf = prefix0.Platform(id: map['id'], platformName: map['platformName'], dueDate: map['dueDate'], totalNum: map['totalNum']);
  return pf;
}


/*
* get method*/
Future<List<String>> getItemsInMonth(String monthString) async {
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db
      .query('MonthTable', where: 'monthString = ?', whereArgs: [monthString]);
  if (maps.length == 1) {
    return maps[0]['monthString'].toString().split('.');
  } else {
    throw 'Map\'s length isn\'t 1, it\'s ' + maps.length.toString();
  }
}

Future<void> delById(int id) async {
  final Database db = await database;
  await db.delete('ItemTable', where: "id = ?", whereArgs: [id]);
}

Future<void> update(Item item) async {
  final Database db = await database;
  await db.update('ItemTable', item.toMap(),
      where: "name = ?", whereArgs: [item.itemName]);
}

Future<SubPlatform> getSubPlatform(String platformName, String monthKey) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query('SubPlatformTable', where: 'platformKey = ? and monthKey = ?', whereArgs: [platformName, monthKey]);
  assert(maps.length < 2, 'Error: The maps length should smaller than 2, check out database. Current length: ' + maps.length.toString());
  if (maps.length == 0) {
    var sp = SubPlatform(monthKey: monthKey, platformKey: platformName, numThisStage: 0);
    int i =  await insertDate(sp);
    sp.id = i;
    return sp;
  }
  return SubPlatform.mapTo(maps[0]);
}

Future<List<SubPlatform>> getSubPlatformByMonth(String monthKey) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query('SubPlatformTable', where: 'monthKey = ?', whereArgs: [monthKey]);
  List<SubPlatform> list = List();
  for (var o in maps) {
    list.add(SubPlatform.mapTo(o));
  }
  return list;
}

Future<void> updateSubPlatform(SubPlatform subPlatform) async {
  final Database db = await database;
  await db.update('SubPlatformTable', subPlatform.toMap(), where: 'id = ?', whereArgs: [subPlatform.id]);
}

Future<void> updatePlatform(Platform platform) async{
  final Database db = await database;
  await db.update('PlatformTable', platform.toMap(), where: 'id = ?', whereArgs: [platform.id]);
}

Future<List<Item>> getItem(String platformKey) async {
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query('ItemTable', where: 'platformKey = ?', whereArgs: [platformKey]);
  List<Item> items = List();
  for (var o in maps) {
    items.add(Item.mapTo(o));
  }
  return items;
}