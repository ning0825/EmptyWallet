import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/db/item_bean.dart' as prefix0;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'item_bean.dart';

var database;
var dbName = "debt_database.db";

const PLATFORM_TABLE_NAME = 'PlatformTable';
const SUBPLATFORM_TABLE_NAME = 'SubPlatformTable';
const ITEM_TABLE_NAME = 'ItemTable';
const SUBITEM_TABLE_NAME = 'SubItemTable';
const HUMANLOAN_TABLE_NAME = 'HumanLoanTable';
const SUBHUMAN_TABLE_NAME = 'SubHumanTable';
const MONTH_TABLE_NAME = 'MonthTable';

const CREATE_PLATFORM_TABLE = '''
    CREATE TABLE $PLATFORM_TABLE_NAME(
          id INTEGER PRIMARY KEY,
          platformName TEXT,
          dueDate TEXT,
          totalNum REAL
    )
      ''';
const CREATE_SUBPLATFORM_TABLE = '''
    CREATE TABLE $SUBPLATFORM_TABLE_NAME(
          id INTEGER PRIMARY KEY,
          monthKey TEXT,
          platformKey TEXT,  
          numThisStage REAL, 
          dateThisStage TEXT,
          isPaidOff INT
    )
    ''';
const CREATE_ITEM_TABLE = '''
    CREATE TABLE $ITEM_TABLE_NAME(
          id INTEGER PRIMARY KEY,
          platformKey TEXT,
          itemName TEXT,
          stageNum INT,
          numPerStage REAL,
          paidStageNum INT
    )
''';
const CREATE_SUBITEM_TABLE = '''
    CREATE TABLE $SUBITEM_TABLE_NAME(
          id INTEGER PRIMARY KEY,
          itemKey TEXT,
          monthKey TEXT,
          numThisStage REAL,
          currentStage INT,
          isPaidOff INT
    )
    ''';
const CREATE_HUMANLOAN_TABLE = '''
    CREATE TABLE $HUMANLOAN_TABLE_NAME(
           id INTEGER PRIMARY KEY,
           hName TEXT,
           hTotal REAL,
           hPaid REAL,
           hNotPaid REAL
    )
    ''';
const CREATE_SUBHUMAN_TABLE = '''
    CREATE TABLE $SUBHUMAN_TABLE_NAME(
          id INTEGER PRIMARY KEY,
          sName TEXT,
          subNum REAL,
          loanDate TEXT,
          paymentMethod INT,
          currentTotal REAL
    )
''';

const CREATE_MONTH_TABLE  = '''
    CREATE TABLE $MONTH_TABLE_NAME(
          id INTEGER PRIMARY KEY,
          month TEXT,
          monthTotal REAL
    )
''';
//Many app have one database and would never need to close it, it will be closed when the app is terminated.
Future<void>  openDB() async {
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
      db.execute(CREATE_HUMANLOAN_TABLE);
      db.execute(CREATE_SUBHUMAN_TABLE);
      db.execute(CREATE_MONTH_TABLE);
    },
    version: 1,
  );
}

//insert method.
Future<int> insertDate(dynamic dn) async {
  final Database db = await database;
  return await db.insert(dn.runtimeType.toString() + 'Table', dn.toMap());
}

//get humanloans.
Future<List<HumanLoan>> getHls() async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(HUMANLOAN_TABLE_NAME);
  List<HumanLoan> list = [];
  for (var o in maps) {
    list.add(HumanLoan.mapTo(o));
  }
  return list;
}

//get subhuman by name.
Future<List<SubHuman>> getSubHumanByName(String name) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(SUBHUMAN_TABLE_NAME, where: 'sName = ?', whereArgs: [name]);
  List<SubHuman> list = [];
  for (var o in maps) {
    list.add(SubHuman.mapTo(o));
  }
  return list;
}

//get human loan by name.
Future<HumanLoan> getHlByName(String name) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(HUMANLOAN_TABLE_NAME, where: 'hName = ?', whereArgs: [name]);
  if(maps.length == 0) {
    return null;
  }
  Map<String, dynamic> map = maps[0];
  return prefix0.HumanLoan(id: map['id'], hName: map['hName'], hTotal: map['hTotal'], hPaid: map['hPaid'], hNotPaid: map['hNotPaid']);
}

//get platform by name.
Future<Platform> getPlatformByName(String name) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(PLATFORM_TABLE_NAME, where: 'platformName = ?', whereArgs: [name]);
  print('getPf: maps.length: ' + maps.length.toString());
  if(maps.length == 0) {
    return null;
  }
  Map<String, dynamic> map = maps[0];
  var pf = prefix0.Platform(id: map['id'], platformName: map['platformName'], dueDate: map['dueDate'], totalNum: map['totalNum']);
  return pf;
}

//delete specific item.
//Future<void> delById(int id) async {
//  final Database db = await database;
//  await db.delete(ITEM_TABLE_NAME, where: "id = ?", whereArgs: [id]);
//}

//update specific item.
//Future<void> update(Item item) async {
//  final Database db = await database;
//  await db.update(ITEM_TABLE_NAME, item.toMap(),
//      where: "name = ?", whereArgs: [item.itemName]);
//}

//get subplatform.
Future<SubPlatform> getSubPlatform(String platformName, String monthKey) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(SUBPLATFORM_TABLE_NAME, where: 'platformKey = ? and monthKey = ?', whereArgs: [platformName, monthKey]);
  assert(maps.length < 2, 'Error: The maps length should smaller than 2, check out database. Current length: ' + maps.length.toString());
  if (maps.length == 0) {
    Platform pf = await getPlatformByName(platformName);
    var sp = SubPlatform(monthKey: monthKey, platformKey: platformName, numThisStage: 0, dateThisStage: monthKey + '.' + pf.dueDate);
    int i =  await insertDate(sp);
    sp.id = i;
    return sp;
  }
  return SubPlatform.mapTo(maps[0]);
}

Future<List<Month>> getMonths() async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(MONTH_TABLE_NAME);
  List<Month> list = [];
  for (var o in maps) {
    list.add(Month(id: o['id'], month: o['month'], monthTotal: o['monthTotal']));
  }
  return list;
}

Future<Month> getMonth(String month) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(MONTH_TABLE_NAME, where: 'month = ?', whereArgs: [month]);
  assert(maps.length < 2, 'Error, List of query specific month length should not larger than 1');
  if(maps.length == 0) {
    return null;
  }
  var map = maps[0];
  return Month(id: map['id'], month: map['month'], monthTotal: map['monthTotal']);
}

//get subplatforms in month.
Future<List<SubPlatform>> getSubPlatformsByMonth(String monthKey) async{
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(SUBPLATFORM_TABLE_NAME, where: 'monthKey = ?', whereArgs: [monthKey]);
  List<SubPlatform> list = List();
  for (var o in maps) {
    list.add(SubPlatform.mapTo(o));
  }
  return list;
}

//update specific subplatform.
Future<void> updateSubPlatform(SubPlatform subPlatform) async {
  final Database db = await database;
  await db.update(SUBPLATFORM_TABLE_NAME, subPlatform.toMap(), where: 'id = ?', whereArgs: [subPlatform.id]);
}

//update specific platform.
Future<void> updatePlatform(Platform platform) async{
  final Database db = await database;
  await db.update(PLATFORM_TABLE_NAME, platform.toMap(), where: 'id = ?', whereArgs: [platform.id]);
}

//update human.
Future<void> updateHuman(HumanLoan humanLoan) async{
  final Database db = await database;
  await db.update(HUMANLOAN_TABLE_NAME, humanLoan.toMap(), where: 'id = ?', whereArgs: [humanLoan.id]);
}

//update month
Future<void> updateMonth(Month month) async{
  final Database db = await database;
  await db.update(MONTH_TABLE_NAME, month.toMap(), where: 'id = ?', whereArgs: [month.id]);
}

//get items in platform.
Future<List<Item>> getItems(String platformKey) async {
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(ITEM_TABLE_NAME, where: 'platformKey = ?', whereArgs: [platformKey]);
  List<Item> items = List();
  for (var o in maps) {
    items.add(Item.mapTo(o));
  }
  return items;
}

Future<void> updateItem(Item item) async{
  final Database db = await database;
  await db.update(SUBITEM_TABLE_NAME, item.toMap(), where: 'id = ?', whereArgs: [item.id]);
}

Future<SubItem> getSubItem(String itemKey, String monthKey) async {
  final Database db = await database;
  List<Map<String, dynamic>> maps = await db.query(SUBITEM_TABLE_NAME, where: 'itemKey = ? and monthKey = ?', whereArgs: [itemKey, monthKey]);
  return SubItem.mapTo(maps[0]);
}

Future<void> updateSubItem(SubItem subItem) async{
  final Database db = await database;
  await db.update(SUBITEM_TABLE_NAME, subItem.toMap(), where: 'id = ?', whereArgs: [subItem.id]);
}