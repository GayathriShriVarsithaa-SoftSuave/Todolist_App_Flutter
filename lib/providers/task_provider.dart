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
  }

  Future<void> loadTasks() async {
    try {
      final uid = currentUserId;

      if (uid == null) {
        tasks = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      tasks = await _dbHelper.getAllTask(uid);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String name, String description) async {
    final uid = currentUserId;
    if (uid == null) return;
    final createdAt = DateTime.now().toIso8601String();

    await _dbHelper.insertTask(uid, name, description, createdAt, 0);
    await loadTasks();
  }

  Future<void> changeCompletedStatus({
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
    await loadTasks();
  }
}
