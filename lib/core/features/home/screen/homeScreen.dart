import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/taskItem.dart';

import 'package:provider/provider.dart';

import '../../../providers/task_provider.dart';

import 'package:fluttertoast/fluttertoast.dart';

import './../../../services/toast_msg.dart';

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
      showToastMsg(
        'Please enter a task name',
        Colors.deepOrangeAccent,
        Toast.LENGTH_SHORT,
      );
      return false;
    }

    await context.read<TaskProvider>().addTaskWithTags(
      tasknamecontroller.text.trim(),
      taskdetailscontroller.text.trim(),
      List<String>.from(selectedTags),
    );
    showToastMsg(
        'Added',
        Colors.green,
        Toast.LENGTH_LONG,
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
    const backgroundColor = Color.fromRGBO(13, 43, 29, 1);
    const foregroundColor = Color.fromRGBO(0, 230, 118, 1);
    const cardColor = Color.fromRGBO(22, 61, 43, 1);
    const textColor = Color.fromRGBO(255, 255, 255, 1);
    const borderColor = Color.fromRGBO(45, 90, 67, 1);
    final taskProvider = context.watch<TaskProvider>();
    // TODO: implement build
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('To Do List', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/profile');
            },
            icon: Icon(Icons.person),
            color: textColor,
          ),
        ],
      ),
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
                              hintStyle: TextStyle(color: Color(0xFFB8A7D9)),
                              prefixIcon: Icon(Icons.search, color: textColor),
                              filled: true,
                              fillColor: cardColor,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: foregroundColor),
                              ),
                            ),
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          logout();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color(0xFF7F1D1D),
                          foregroundColor: textColor,
                          side: BorderSide(color: Color(0xFFFF8A8A)),
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
                            checkmarkColor: foregroundColor,
                            labelStyle: TextStyle(color: textColor),
                            backgroundColor: cardColor,
                            selectedColor: Color(0xFF475569),
                            side: BorderSide(color: foregroundColor),
                            label: Text('All'),
                            selected: taskProvider.selectedTagId == null,
                            onSelected: (_) {
                              taskProvider.selectTag(null);
                            },
                          ),
                          ...taskProvider.availableTags.map((tag) {
                            final tagId = tag['tag_id'] as int;

                            return ChoiceChip(
                              checkmarkColor: foregroundColor,
                              labelStyle: TextStyle(color: textColor),
                              backgroundColor: cardColor,
                              selectedColor: Color(0xFF475569),
                              side: BorderSide(color: foregroundColor),
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
                      ? Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              foregroundColor,
                            ),
                          ),
                        )
                      : taskProvider.filteredTasks.isEmpty
                      ? taskProvider.searchQuerey.isEmpty
                            ? Center(
                                child: Text(
                                  'No tasks yet. Add your first task!',
                                  style: TextStyle(color: textColor),
                                ),
                              )
                            : Center(
                                child: Text(
                                  'No matching tasks found',
                                  style: TextStyle(color: textColor),
                                ),
                              )
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
        backgroundColor: foregroundColor,
        foregroundColor: backgroundColor,
        onPressed: () {
          {
            tasknamecontroller.clear();
            taskdetailscontroller.clear();
            selectedTags.clear();
            tagcontroller.clear();
            showModalBottomSheet(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
                                  color: textColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            TextField(
                              onChanged: (value) {
                                setModalState(() {});
                              },
                              controller: tasknamecontroller,
                              style: TextStyle(color: foregroundColor),
                              decoration: InputDecoration(
                                hintText: 'Task name',
                                hintStyle: TextStyle(color: textColor),
                                filled: true,
                                fillColor: cardColor,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: foregroundColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            TextField(
                              controller: taskdetailscontroller,
                              maxLines: 4,
                              style: TextStyle(color: foregroundColor),
                              decoration: InputDecoration(
                                hintText: 'Enter task description',
                                hintStyle: TextStyle(color: textColor),
                                filled: true,
                                fillColor: cardColor,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: foregroundColor,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16),
                            Text(
                              'Select Tags',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
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
                                    selectedColor: Color(0xFF475569),
                                    checkmarkColor: foregroundColor,
                                    label: Text(tagName),
                                    labelStyle: TextStyle(color: textColor),
                                    backgroundColor: cardColor,
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
                                    style: TextStyle(color: textColor),
                                    controller: tagcontroller,
                                    decoration: InputDecoration(
                                      hintText: 'Create new tag',
                                      hintStyle: TextStyle(color: textColor),
                                      filled: true,
                                      fillColor: cardColor,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: borderColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: foregroundColor,
                                        ),
                                      ),
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
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: foregroundColor,
                                  ),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),

                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 8,
                                  children: selectedTags.map((tag) {
                                    return Chip(
                                      labelStyle: TextStyle(color: textColor),
                                      backgroundColor: cardColor,
                                      side: BorderSide(
                                        color: foregroundColor,
                                        width: 1.5,
                                      ),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: foregroundColor,
                                  foregroundColor: backgroundColor,
                                  disabledBackgroundColor: borderColor,
                                  disabledForegroundColor: Colors.white54,
                                ),
                                onPressed:
                                    tasknamecontroller.text.trim().isEmpty
                                    ? null
                                    : () async {
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
    );
  }
}
