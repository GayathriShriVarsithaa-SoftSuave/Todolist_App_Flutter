import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './../widgets/taskItem.dart';

import 'package:provider/provider.dart';

import './../providers/task_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  final searchcontroller = TextEditingController();
  final tasknamecontroller = TextEditingController();
  final taskdetailscontroller = TextEditingController();
  Future<bool> insertTasktodb() async {
    if (tasknamecontroller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task name')));
      return false;
    }

    await context.read<TaskProvider>().addTask(
      tasknamecontroller.text.trim(),
      taskdetailscontroller.text.trim(),
    );
    return true;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchcontroller.dispose();
    taskdetailscontroller.dispose();
    tasknamecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    // TODO: implement build
    return (Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentGeometry.topLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(10),
                          child: TextField(
                            controller: searchcontroller,
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              context.read<TaskProvider>().searchTask(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search Tasks..',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          logout();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.red),
                        ),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: taskProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : taskProvider.filteredTasks.isEmpty
                      ? taskProvider.searchQuerey.isEmpty
                            ? Center(
                                child: Text(
                                  'No tasks yet. Add your first task!',
                                ),
                              )
                            : Center(child: Text('No matching tasks found'))
                      : ListView.builder(
                          itemCount: taskProvider.filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = taskProvider.filteredTasks[index];

                            return TaskItem(
                              id: task['id'] as int,
                              taskname: task['task_name'] as String,
                              taskdes: task['task_des'] as String? ?? '',
                              createdAt: task['created_at'] as String,
                              completed: task['completed'] as int,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          {
            tasknamecontroller.clear();
            taskdetailscontroller.clear();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: tasknamecontroller,
                        decoration: InputDecoration(
                          hintText: 'Task name',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: taskdetailscontroller,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter task description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),

                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final isSaved = await insertTasktodb();

                          if (isSaved && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Save Task'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
        child: Icon(Icons.add),
      ),
    ));
  }
}
