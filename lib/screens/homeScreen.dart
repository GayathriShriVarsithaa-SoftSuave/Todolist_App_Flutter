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
  final tagcontroller = TextEditingController();
  final List<String> selectedTags = [];
  Future<bool> insertTasktodb() async {
    if (tasknamecontroller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a task name')));
      return false;
    }

    await context.read<TaskProvider>().addTaskWithTags(
      tasknamecontroller.text.trim(),
      taskdetailscontroller.text.trim(),
      List<String>.from(selectedTags),
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
    tagcontroller.dispose();
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
            padding: EdgeInsets.all(8.0),
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

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: AlignmentGeometry.topStart,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text('All'),
                            selected: taskProvider.selectedTagId == null,
                            onSelected: (_) {
                              taskProvider.selectTag(null);
                            },
                          ),
                          ...taskProvider.availableTags.map((tag) {
                            final tagId = tag['tag_id'] as int;

                            return ChoiceChip(
                              label: Text(tag['tag_name'] as String),
                              selected: taskProvider.selectedTagId == tagId,
                              onSelected: (_) {
                                taskProvider.selectTag(
                                  taskProvider.selectedTagId == tagId
                                      ? null
                                      : tagId,
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                Expanded(
                  child: taskProvider.isLoading
                      ? Center(child: CircularProgressIndicator.adaptive())
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
            selectedTags.clear();
            tagcontroller.clear();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        20,
                        16,
                        MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Add Task',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            TextField(
                              controller: tasknamecontroller,
                              decoration: InputDecoration(
                                hintText: 'Task name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),

                            TextField(
                              controller: taskdetailscontroller,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Enter task description',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            SizedBox(height: 16),
                            Text(
                              'Select Tags',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 8,
                                children: taskProvider.availableTags.map((tag) {
                                  final tagName = tag['tag_name'] as String;
                                  final isSelected = selectedTags.contains(
                                    tagName,
                                  );

                                  return FilterChip(
                                    label: Text(tagName),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setModalState(() {
                                        if (selected) {
                                          if (!selectedTags.contains(tagName)) {
                                            selectedTags.add(tagName);
                                          }
                                        } else {
                                          selectedTags.remove(tagName);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),

                            SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: tagcontroller,
                                    decoration: InputDecoration(
                                      hintText: 'Create new tag',
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (_) {
                                      final name = tagcontroller.text.trim();

                                      if (name.isNotEmpty &&
                                          !selectedTags.any(
                                            (tag) =>
                                                tag.toLowerCase() ==
                                                name.toLowerCase(),
                                          )) {
                                        setModalState(() {
                                          selectedTags.add(name);
                                          tagcontroller.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle),
                                  onPressed: () {
                                    final name = tagcontroller.text.trim();

                                    if (name.isNotEmpty &&
                                        !selectedTags.any(
                                          (tag) =>
                                              tag.toLowerCase() ==
                                              name.toLowerCase(),
                                        )) {
                                      setModalState(() {
                                        selectedTags.add(name);
                                        tagcontroller.clear();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),

                            if (selectedTags.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                'Selected Tags',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 8,
                                  children: selectedTags.map((tag) {
                                    return Chip(
                                      label: Text(tag),
                                      onDeleted: () {
                                        setModalState(() {
                                          selectedTags.remove(tag);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],

                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final isSaved = await insertTasktodb();

                                  if (isSaved && context.mounted) {
                                    selectedTags.clear();
                                    tagcontroller.clear();
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Save Task'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
