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
      version: 2, // Increment version to trigger onUpgrade
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add new tables or schema changes
          await _createTables(db);
        }
      },
    );
  }
  Future<List<Map<String, dynamic>>> getAllEvents() async {
  try {
    final db = await database;
    return await db.query('events');
  } catch (e) {
    throw Exception('Failed to fetch all events: $e');
  }
}

  Future<void> _createTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        name TEXT NOT NULL,
        time TEXT NOT NULL,
        group_id INTEGER,
        location_id INTEGER,
        is_holiday INTEGER DEFAULT 0,
        FOREIGN KEY(group_id) REFERENCES groups(id),
        FOREIGN KEY(location_id) REFERENCES locations(id)
      )
    ''');

    // Groups table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Locations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT
      )
    ''');
}
  // Users
  Future<int> registerUser(String email, String password) async {
    try {
      final db = await database;
      return await db.insert('users', {'email': email, 'password': password});
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email existence: $e');
    }
  }
  // Update password in the database
  Future<int> updatePassword(String email, String newPassword) async {
    try {
      final db = await database;
      return await db.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Events
  Future<int> insertEvent(Map<String, dynamic> event) async {
    try {
      final db = await database;
      return await db.insert('events', event);
    } catch (e) {
      throw Exception('Failed to insert event: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEventsByDate(String date) async {
    try {
      final db = await database;
      return await db.query(
        'events',
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'time ASC',
      );
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<int> updateEvent(Map<String, dynamic> event) async {
  try {
    final db = await database;
    return await db.update(
      'events',
      event,
      where: 'id = ?',
      whereArgs: [event['id']],
    );
  } catch (e) {
    throw Exception('Failed to update event: $e');
  }
}



  Future<int> deleteEvent(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Groups
  Future<int> insertGroup(Map<String, dynamic> group) async {
    try {
      final db = await database;
      return await db.insert('groups', group);
    } catch (e) {
      throw Exception('Failed to insert group: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGroups() async {
    try {
      final db = await database;
      return await db.query('groups', orderBy: 'name ASC');
    } catch (e) {
      throw Exception('Failed to fetch groups: $e');
    }
  }

  // Locations
  Future<int> insertLocation(Map<String, dynamic> location) async {
    try {
      final db = await database;
      return await db.insert('locations', location);
    } catch (e) {
      throw Exception('Failed to insert location: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      final db = await database;
      return await db.query('locations', orderBy: 'name ASC');
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  // Close the database
  Future close() async {
    final db = await database;
    await db.close();
  }
}
