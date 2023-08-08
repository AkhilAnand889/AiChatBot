import 'dart:async';

import 'package:aibot/model/response_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initializeDatabase();
    return _database;
  }

  static Future<Database> initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'your_database_name.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE responses(
            id TEXT PRIMARY KEY,
            question TEXT,
            data TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertResponse(ResponseData responseData) async {
    final db = await database;
    await db!.insert(
      'responses',
      responseData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ResponseData>> getResponsesById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'responses',
      where: 'id = ?',
      whereArgs: [id],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (index) {
      return ResponseData.fromMap(maps[index]);
    });
  }

static Future<List<ResponseData>> getAllResponsesByIdAndQuestion(
   String id, String question) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db!.query(
    'responses',
    where: 'id = ? AND question = ?',
    whereArgs: [id, question],
  );
  return List.generate(maps.length, (index) {
    return ResponseData.fromMap(maps[index]);
  });
}

  static Future<List<String>> getAllIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'responses',
      columns: ['id'],
      distinct: true,
    );
    return List.generate(maps.length, (index) {
      return maps[index]['id'] as String;
    });
  }

  static Future<void> deleteResponsesById(String id) async {
    final db = await database;
    await db!.delete(
      'responses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAllResponses() async {
    final db = await database;
    await db!.delete('responses');
  }


  // Add a close method to close the database when not needed
  static Future<void> close() async {
    final db = await database;
    db!.close();
    _database = null;
  }
}
