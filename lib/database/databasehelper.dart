import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseahelper {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'task.db');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE TASKS(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_name TEXT,
  task_des TEXT,
  created_at TEXT,
  updated_at TEXT,
  completed INTEGER
)
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE TASKS ADD COLUMN task_des TEXT');
        }
      },
    );
    return _database!;
  }

  //Add a task

  Future<int> insertTask(
    String taskname,
    String taskdes,
    String createdAt,
    int completed,
  ) async {
    final db = await database;
    return await db.insert('TASKS', {
      'task_name': taskname,
      'task_des': taskdes,
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
    String taskdes,
    String CreatedAt,
    String UpdatedAt,
    int Completed,
  ) async {
    final db = await database;
    return await db.update(
      'TASKS',
      {
        'task_name': taskName,
        'task_des': taskdes,
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
    return await db.query('TASKS', where: 'id=?', whereArgs: [id]);
  }
}
