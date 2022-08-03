import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;
  DatabaseHelper._instance();

  String taskTable = 'task_Table';
  String colId = 'id';
  String colTitle = 'title';
  String colBody = 'description';
  String colPriority = 'priority';
  String colTime = 'time';
  String colDate = 'date';

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'task_list.db';
    print('print $path');
    final taskListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return taskListDb;
    print('tasklist = $taskListDb');
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $taskTable (
          $colId INTEGER PRIMARY KEY AUTOINCREMENT,
          $colTitle TEXT ,
          $colBody TEXT ,
          $colPriority TEXT,
          $colDate TEXt,
          $colTime TEXt)''');
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(
      taskTable,orderBy: '$colDate ASC ,$colPriority ASC ' 
    );
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();

    final List<Task> tasklist = [];

    for (var element in taskMapList) {
      tasklist.add(Task.fromMap(element));
    }

    return tasklist;
  }

  Future<int> insertTask(Task task) async {
    print('insert method called');
    Database? db = await this.db;
    final int result = await db!.insert(taskTable, task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database? db = await this.db;
    print('update method called');
    final int result = await db!.update(taskTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  Future<int> deleteTask(Task task) async {
    Database? db = await this.db;
    final int result =
        await db!.delete(taskTable, where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }
}
