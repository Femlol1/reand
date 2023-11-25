import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'tasks';

  static Future<void> initDb() async {
    databaseFactory = databaseFactoryFfi;
// Checking if the database is already initialized.
    if (_db != null) {
      debugPrint('db not null');
      return;
    }
    try {
      // Constructing the database path and opening the database.
      String path = '${await getDatabasesPath()}task.db';
      debugPrint('in db path');
      _db = await openDatabase(path, version: _version,
          onCreate: (Database db, int version) async {
        debugPrint('Creating new one');
        // When creating the db, create the table
        return db.execute('CREATE TABLE $_tableName ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title STRING, note TEXT, date STRING, '
            'startTime STRING, endTime STRING, '
            'remind INTEGER, repeat STRING, '
            'color INTEGER, '
            'isCompleted INTEGER)');
      });
      // print('DB Created');
    } catch (e) {
      print(e);
    }
  }

// Inserts a new task into the database.
  static Future<int> insert(Task? task) async {
    //debugPrint('insert function called');
    try {
      return await _db!.insert(_tableName, task!.toJson());
    } catch (e) {
      return 9000;
    }
  }

// Deletes a specific task from the database.
  static Future<int> delete(Task task) async {
    // print('insert');
    return await _db!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

// Deletes all tasks from the database.
  static Future<int> deleteAll() async {
    // print('insert');
    return await _db!.delete(_tableName);
  }

  // Queries and returns all tasks from the database.
  static Future<List<Map<String, dynamic>>> query() async {
    //debugPrint('Query Called!!!!!!!!!!!!!!!!!!!');
    return await _db!.query(_tableName);
  }

  // Updates a specific task's completion status.
  static Future<int> update(int id) async {
    //debugPrint('update ');
    return await _db!.rawUpdate(
        '''
    UPDATE tasks
    SET isCompleted = ?
    WHERE id = ?
    ''',
        [1, id]);
  }
}
