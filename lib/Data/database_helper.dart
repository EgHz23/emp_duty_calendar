import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Fetch events for a specific date
  Future<List<Map<String, dynamic>>> getEventsByDate(String date) async {
    final db = await database;
    return await db.query(
      'events',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time ASC',
    );
  }

  /// Insert a new event
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('events', event);
  }

  /// Update an existing event
  Future<int> updateEvent(int id, Map<String, dynamic> updatedEvent) async {
    final db = await database;
    return await db.update(
      'events',
      updatedEvent,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete an event by ID
  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fetch all events (optional utility)
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    return await db.query('events', orderBy: 'date ASC, time ASC');
  }
}
