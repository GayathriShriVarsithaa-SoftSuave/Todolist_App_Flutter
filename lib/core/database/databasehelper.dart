import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseahelper {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'task.db');
    _database = await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE TASKS(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  uid TEXT,
  task_name TEXT,
  task_des TEXT,
  created_at TEXT,
  updated_at TEXT,
  completed INTEGER
)
''');
        await db.execute('''
CREATE TABLE TAGS(
tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
tag_name TEXT NOT NULL UNIQUE
)
''');
        await db.execute('''
    CREATE TABLE TASK_TAGS (
      task_id INTEGER NOT NULL,
      tag_id INTEGER NOT NULL,
      PRIMARY KEY (task_id, tag_id),
      FOREIGN KEY (task_id)
        REFERENCES TASKS(id) ON DELETE CASCADE,
      FOREIGN KEY (tag_id)
        REFERENCES TAGS(tag_id) ON DELETE CASCADE
    )
  ''');
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE TASKS ADD COLUMN task_des TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE TASKS ADD COLUMN uid TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('''
    CREATE TABLE TAGS (
      tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
      tag_name TEXT NOT NULL UNIQUE
    )
  ''');

          await db.execute('''
    CREATE TABLE TASK_TAGS (
      task_id INTEGER NOT NULL,
      tag_id INTEGER NOT NULL,
      PRIMARY KEY (task_id, tag_id),
      FOREIGN KEY (task_id)
        REFERENCES TASKS(id) ON DELETE CASCADE,
      FOREIGN KEY (tag_id)
        REFERENCES TAGS(tag_id) ON DELETE CASCADE
    )
  ''');
        }
      },
    );
    return _database!;
  }

  //Add a task

  Future<int> insertTask(
    String uid,
    String taskname,
    String taskdes,
    String createdAt,
    int completed,
  ) async {
    final db = await database;
    return await db.insert('TASKS', {
      'uid': uid,
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
    String uid,
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
        'uid': uid,
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

  Future<List<Map<String, dynamic>>> getAllTask(String uid) async {
    final db = await database;
    return await db.query('TASKS', where: 'uid=?', whereArgs: [uid]);
  }

  //get a particular task

  Future<Map<String, dynamic>?> getTask(int id) async {
    final db = await database;
    final res = await db.query('TASKS', where: 'id=?', whereArgs: [id]);
    if (res.isEmpty) {
      return null;
    }
    return res.first;
  }

  //get task id

  Future<List<int>> getTaskId() async {
    final db = await database;
    final result = await db.query('TASKS', columns: ['id']);
    return result.map((task) => task['id'] as int).toList();
  }

  //task and tags are mapped

  Future<void> addTagToTask(int taskId, int tagId) async {
    final db = await database;

    await db.insert('TASK_TAGS', {
      'task_id': taskId,
      'tag_id': tagId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  //add a new tag. if tag already present it will be not added

  Future<int> insertTag(String tagName) async {
    final db = await database;

    return await db.insert('TAGS', {
      'tag_name': tagName,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  //get all available tags
  Future<List<Map<String, dynamic>>> getAllTags() async {
    final db = await database;
    return db.query('TAGS', orderBy: 'tag_name ASC');
  }

  //get tags for a particular task
  Future<int> getOrCreateTag(String tagName) async {
    final db = await database;
    final name = tagName.trim();

    if (name.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }

    final existing = await db.query(
      'TAGS',
      columns: ['tag_id'],
      where: 'tag_name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first['tag_id'] as int;
    }

    await db.insert('TAGS', {
      'tag_name': name,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Retrieve the ID whether the tag was newly inserted or already existed.
    final result = await db.query(
      'TAGS',
      columns: ['tag_id'],
      where: 'tag_name = ?',
      whereArgs: [name],
      limit: 1,
    );

    return result.first['tag_id'] as int;
  }

  Future<int> insertTaskWithTags({
    required String uid,
    required String taskName,
    required String taskDescription,
    required String createdAt,
    required int completed,
    required List<String> tagNames,
  }) async {
    final db = await database;

    return db.transaction((txn) async {
      final taskId = await txn.insert('TASKS', {
        'uid': uid,
        'task_name': taskName,
        'task_des': taskDescription,
        'created_at': createdAt,
        'updated_at': null,
        'completed': completed,
      });

      for (final rawName in tagNames) {
        final name = rawName.trim();
        if (name.isEmpty) continue;

        final existing = await txn.query(
          'TAGS',
          columns: ['tag_id'],
          where: 'tag_name = ?',
          whereArgs: [name],
          limit: 1,
        );

        final tagId = existing.isNotEmpty
            ? existing.first['tag_id'] as int
            : await txn.insert('TAGS', {'tag_name': name});

        await txn.insert('TASK_TAGS', {
          'task_id': taskId,
          'tag_id': tagId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      return taskId;
    });
  }

  //if no task has the tag, delte it

  Future<void> deleteUnusedTags() async {
    final db = await database;

    await db.delete(
      'TAGS',
      where: '''
      tag_id NOT IN (
        SELECT tag_id FROM TASK_TAGS
      )
    ''',
    );
  }

  //filter based on tag

  Future<List<Map<String, dynamic>>> getTasksByTag(
    String uid,
    int tagId,
  ) async {
    final db = await database;

    return db.rawQuery(
      '''
    SELECT TASKS.*
    FROM TASKS
    INNER JOIN TASK_TAGS
      ON TASKS.id = TASK_TAGS.task_id
    WHERE TASKS.uid = ?
      AND TASK_TAGS.tag_id = ?
    ORDER BY TASKS.id DESC
    ''',
      [uid, tagId],
    );
  }

  Future<void> updateTaskTags(int taskId, List<String> tagNames) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('TASK_TAGS', where: 'task_id = ?', whereArgs: [taskId]);

      for (final name in tagNames.toSet()) {
        final tagName = name.trim();
        if (tagName.isEmpty) continue;

        final existing = await txn.query(
          'TAGS',
          columns: ['tag_id'],
          where: 'LOWER(tag_name) = LOWER(?)',
          whereArgs: [tagName],
          limit: 1,
        );

        final tagId = existing.isNotEmpty
            ? existing.first['tag_id'] as int
            : await txn.insert('TAGS', {'tag_name': tagName});

        await txn.insert('TASK_TAGS', {'task_id': taskId, 'tag_id': tagId});
      }
    });

    await deleteUnusedTags();
  }

  Future<List<Map<String, dynamic>>> getTagsForTask(int taskId) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT TAGS.tag_id, TAGS.tag_name
    FROM TAGS
    INNER JOIN TASK_TAGS
      ON TAGS.tag_id = TASK_TAGS.tag_id
    WHERE TASK_TAGS.task_id = ?
    ORDER BY TAGS.tag_name ASC
    ''',
      [taskId],
    );
  }
}
