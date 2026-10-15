import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './../providers/task_provider.dart';

class TaskItem extends StatefulWidget {
  final int id;
  final String taskname;
  final String taskdes;
  final String createdAt;
  final int completed;
  TaskItem({
    super.key,
    required this.id,
    required this.taskname,
    required this.taskdes,
    required this.createdAt,
    required this.completed,
  });
  @override
  State<StatefulWidget> createState() {
    return _TaskItem();
  }
}

class _TaskItem extends State<TaskItem> {
  final List<String> selectedTags = [];
  final tagcontroller = TextEditingController();
  final tasknamecontroller = TextEditingController();
  final taskdescontroller = TextEditingController();
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    tasknamecontroller.text = widget.taskname;
    taskdescontroller.text = widget.taskdes;
    isChecked = widget.completed == 1;
  }

  @override
  void didUpdateWidget(covariant TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.completed != widget.completed) {
      isChecked = widget.completed == 1;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    taskdescontroller.dispose();
    tasknamecontroller.dispose();
    tagcontroller.dispose();
    super.dispose();
  }

  Future<void> loadTaskTags() async {
    final tags = await context.read<TaskProvider>().getTagsForTask(widget.id);

    selectedTags
      ..clear()
      ..addAll(tags.map((tag) => tag['tag_name'] as String));
  }

  Future<void> changeCompletedStatus(bool value) async {
    await context.read<TaskProvider>().editTask(
      id: widget.id,
      taskname: widget.taskname,
      taskdes: widget.taskdes,
      createdAt: widget.createdAt,
      completed: value,
    );
  }

  Future<void> editFunction(
    int id,
    String taskname,
    String taskdes,
    String createdAt,
    bool value,
  ) async {
    await context.read<TaskProvider>().editTask(
      id: id,
      taskname: taskname,
      taskdes: taskdes,
      createdAt: createdAt,
      completed: value,
    );
  }

  Future<void> deleteTask() async {
    await context.read<TaskProvider>().deleteTask(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (Card(
      elevation: 10,
      child: Row(
        children: [
          Spacer(),
          Checkbox(
            value: isChecked,
            onChanged: (bool? value) async {
              if (value == null) return;
              setState(() {
                isChecked = value;
              });
              await changeCompletedStatus(value);
            },
          ),
          Text(widget.taskname),
          Spacer(),
          IconButton(
            onPressed: () async {
              selectedTags.clear();
              tagcontroller.clear();
              await loadTaskTags();
              if (!context.mounted) return;
              final taskProvider = context.read<TaskProvider>();
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Edit Task',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: tasknamecontroller,
                                    decoration: InputDecoration(
                                      labelText: 'Task name',
                                      border: OutlineInputBorder(),
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    if (value == null) return;
                                    setModalState(() {
                                      isChecked = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: taskdescontroller,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Enter task description',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                            ),
                            SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Tags',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            Align(
                              alignment: AlignmentGeometry.topStart,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 8,
                                  children: taskProvider.availableTags.map((tag) {
                                    final tagName = tag['tag_name'] as String;
                              
                                    return FilterChip(
                                      label: Text(tagName),
                                      selected: selectedTags.contains(tagName),
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
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle),
                                  onPressed: () {
                                    final name = tagcontroller.text.trim();

                                    if (name.isEmpty ||
                                        selectedTags.any(
                                          (tag) =>
                                              tag.toLowerCase() ==
                                              name.toLowerCase(),
                                        )) {
                                      return;
                                    }

                                    setModalState(() {
                                      selectedTags.add(name);
                                      tagcontroller.clear();
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            if (selectedTags.isNotEmpty) 
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Selected Tags',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Align(
                              alignment: AlignmentGeometry.topStart,
                              child: SingleChildScrollView(
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
                            ),

                            SizedBox(height: 16),

                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await editFunction(
                                  widget.id,
                                  tasknamecontroller.text,
                                  taskdescontroller.text,
                                  widget.createdAt,
                                  isChecked,
                                );
                                await taskProvider.updateTaskTags(
                                  widget.id,
                                  List<String>.from(selectedTags),
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              deleteTask();
            },
            icon: Icon(Icons.delete),
          ),
          Spacer(),
        ],
      ),
    ));
  }
}
