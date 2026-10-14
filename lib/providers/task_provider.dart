import 'package:flutter/material.dart';
import './../database/databasehelper.dart';

class TaskProvider extends ChangeNotifier {
  final DataBaseahelper _dbHelper = DataBaseahelper();

  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      tasks = await _dbHelper.getAllTask();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(
    String name,
    String description,
  ) async {
    final createdAt = DateTime.now().toIso8601String();

    await _dbHelper.insertTask(name, description, createdAt, 0);
    await loadTasks();
  }

  Future<void> changeCompletedStatus({
    required int id,
    required String taskname,
    required String taskdes,
    required String createdAt,
    required bool completed,
  }) async {
    final updatedAt = DateTime.now().toIso8601String();

    await _dbHelper.updateTask(
      id,
      taskname,
      taskdes,
      createdAt,
      updatedAt,
      completed ? 1 : 0,
    );

    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    await loadTasks();
  }
}