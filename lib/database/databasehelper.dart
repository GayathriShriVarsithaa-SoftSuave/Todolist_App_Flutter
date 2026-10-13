import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseahelper {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'task.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE TASKS(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_name TEXT,
  created_at TEXT,
  updated_at TEXT,
  completed INTEGER
)
''');
      },
    );
    return _database!;
  }

  //Add a task

  Future<int> insertTask(
    String taskname,
    String createdAt,
    int completed,
  ) async {
    final db = await database;
    return await db.insert('TASKS', {
      'task_name': taskname,
      'created_at': createdAt,
      'updated_at': null,
      'completed': completed,
    });
  }

  //delete a task

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('TASKS', where: 'id=?', whereArgs: [id]);
  }

  //update a task

  Future<int> updateTask(
    int id,
    String taskName,
    String CreatedAt,
    String UpdatedAt,
    int Completed,
  ) async {
    final db = await database;
    return await db.update(
      'TASKS',
      {
        'task_name': taskName,
        'created_at': CreatedAt,
        'updated_at': UpdatedAt,
        'completed': Completed,
      },
      where: 'id=?',
      whereArgs: [id],
    );
  }

  //get all the tasks

  Future<List<Map<String, dynamic>>> getAllTask() async {
    final db = await database;
    return await db.query('TASKS');
  }

  //get a particular task

  Future<List<Map<String, dynamic>>> getTask(int id) async {
    final db = await database;
    return await db.query('TASKS',where: 'id=?',whereArgs: [id]);
  }
}
