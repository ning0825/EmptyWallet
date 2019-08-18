import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Item.dart';

var database;
var dbName = "debt_database.db";

void openDB() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, dbName);
  // Make sure the directory exists
  try {
    await Directory(databasesPath).create(recursive: true);
  } catch (_) {}
  database = await openDatabase(path, onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE debts(id INTEGER PRIMARY KEY, name TEXT, num REAL, fen INT, dateTime TEXT)",
    );
  }, version: 1);
}

Future<void> insertDebt(Item item) async{
  final Database db = await database;
  await db.insert('debts', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
}

Future<List<Item>> getDebts() async{
  final Database db = await database;
  final List<Map<String, dynamic>> maps = await db.query('debts');
  return List.generate(maps.length, (i) {
    return Item(
      name: maps[i]['name'],
      num: maps[i]['num'],
      fen: maps[i]['fen'],
      dateTime: maps[i]['dateTime'],
    );
  });
}

Future<void> delById(int id) async{
  await database.delete('debts',
    // Use a `where` clause to delete a specific dog.
    where: "id = ?",
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [id]);
}

Future<void> update(Item item) async{
  await database.update('debts', item.toMap(), where: "name = ?", whereArgs: [item.name]);
}
