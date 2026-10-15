import 'package:flutter/material.dart';

import './../database/databasehelper.dart';

import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider extends ChangeNotifier {
  final DataBaseahelper _dbHelper = DataBaseahelper();

  String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  TaskProvider() {
    loadTasks();
    loadTags();
  }

  String searchQuerey = '';
  List<Map<String, dynamic>> availableTags = [];

  int? selectedTagId;
  void searchTask(String query) {
    searchQuerey = query;
    applyFilters();
  }

  void selectTag(int? tagId) {
    selectedTagId = tagId;
    applyFilters();
  }

  Future<void> loadTags() async {
    availableTags = await _dbHelper.getAllTags();
    notifyListeners();
  }

  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    try {
      final uid = currentUserId;

      if (uid == null) {
        tasks = [];
        filteredTasks = [];
        return;
      }

      if (selectedTagId == null) {
        tasks = await _dbHelper.getAllTask(uid);
      } else {
        tasks = await _dbHelper.getTasksByTag(uid, selectedTagId!);
      }

      if (searchQuerey.isEmpty) {
        filteredTasks = tasks;
      } else {
        filteredTasks = tasks.where((task) {
          return task['task_name'].toString().toLowerCase().contains(
            searchQuerey.toLowerCase(),
          );
        }).toList();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters() async {
    final uid = currentUserId;

    if (uid == null) {
      filteredTasks = [];
      notifyListeners();
      return;
    }

    if (selectedTagId == null) {
      tasks = await _dbHelper.getAllTask(uid);
    } else {
      tasks = await _dbHelper.getTasksByTag(uid, selectedTagId!);
    }

    if (searchQuerey.isNotEmpty) {
      filteredTasks = tasks.where((task) {
        return task['task_name'].toString().toLowerCase().contains(
          searchQuerey.toLowerCase(),
        );
      }).toList();
    } else {
      filteredTasks = tasks;
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> filteredTasks = [];

  Future<void> addTask(String name, String description) async {
    final uid = currentUserId;
    if (uid == null) return;
    final createdAt = DateTime.now().toIso8601String();

    await _dbHelper.insertTask(uid, name, description, createdAt, 0);
    await loadTasks();
  }

  Future<void> editTask({
    required int id,
    required String taskname,
    required String taskdes,
    required String createdAt,
    required bool completed,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;
    final updatedAt = DateTime.now().toIso8601String();

    await _dbHelper.updateTask(
      id,
      uid,
      taskname,
      taskdes,
      createdAt,
      updatedAt,
      completed ? 1 : 0,
    );

    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _dbHelper.deleteTask(id);
    await _dbHelper.deleteUnusedTags();
    await loadTasks();
    await loadTags();
  }

  Future<void> addTaskWithTags(
    String name,
    String description,
    List<String> tagNames,
  ) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _dbHelper.insertTaskWithTags(
      uid: uid,
      taskName: name,
      taskDescription: description,
      createdAt: DateTime.now().toIso8601String(),
      completed: 0,
      tagNames: tagNames,
    );

    await loadTasks();
    await loadTags();
  }

  Future<List<Map<String, dynamic>>> getTagsForTask(int taskId) {
  return _dbHelper.getTagsForTask(taskId);
}

Future<void> updateTaskTags(int taskId, List<String> tagNames) async {
  await _dbHelper.updateTaskTags(taskId, tagNames);
  await loadTags();
}
  
}
