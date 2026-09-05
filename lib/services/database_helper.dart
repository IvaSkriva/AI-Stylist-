import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/clothing_item.dart';

/// Thin wrapper around a local sqflite database that persists the user's
/// closet on-device. There is no backend/server for this MVP: every photo
/// and tag stays on the phone.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _tableName = 'clothing_items';
  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }
    final opened = await _openDatabase();
    _database = opened;
    return opened;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, 'ai_stylist.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            imagePath TEXT NOT NULL,
            category TEXT NOT NULL,
            color TEXT NOT NULL,
            name TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<ClothingItem>> getAllItems() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'createdAt DESC');
    return rows.map(ClothingItem.fromMap).toList();
  }

  Future<void> insertItem(ClothingItem item) async {
    final db = await database;
    await db.insert(
      _tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
