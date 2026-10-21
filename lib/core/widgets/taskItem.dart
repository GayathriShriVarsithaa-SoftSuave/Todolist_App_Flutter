import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';

import './../services/toast_msg.dart';

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
  final List<String> originalTags = [];
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
    final tagNames = tags.map((tag) => tag['tag_name'] as String).toList();
    selectedTags
      ..clear()
      ..addAll(tagNames);
    originalTags
      ..clear()
      ..addAll(tagNames);
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
    showToastMsg(
        'Edited',
        Colors.green,
        Toast.LENGTH_LONG,
      );
  }

  Future<void> deleteTask() async {
    await context.read<TaskProvider>().deleteTask(widget.id);
    showToastMsg(
        'Deleted',
        Colors.green,
        Toast.LENGTH_LONG,
      );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromRGBO(13, 43, 29, 1);
    const foregroundColor = Color.fromRGBO(0, 230, 118, 1);
    const textColor = Color.fromRGBO(255, 255, 255, 1);
    const cardColor = Color.fromRGBO(22, 61, 43, 1);
    const borderColor = Color.fromRGBO(45, 90, 67, 1);
    // TODO: implement build
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              activeColor: foregroundColor,
              checkColor: backgroundColor,
              side: BorderSide(color: foregroundColor),
              value: isChecked,
              onChanged: (bool? value) async {
                if (value == null) return;
                setState(() {
                  isChecked = value;
                });
                await changeCompletedStatus(value);
              },
            ),
            Expanded(
              child: Text(
                widget.taskname,
                style: TextStyle(color: textColor, fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            Spacer(),
            IconButton(
              color: textColor,
              onPressed: () async {
                selectedTags.clear();
                tagcontroller.clear();
                await loadTaskTags();
                final originalCompleted = widget.completed == 1;
                final originalTagsSnapshot = List<String>.from(originalTags);
                if (!context.mounted) return;
                final taskProvider = context.read<TaskProvider>();
                showModalBottomSheet(
                  backgroundColor: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        final hasChanges =
                            tasknamecontroller.text.trim() != widget.taskname ||
                            taskdescontroller.text.trim() != widget.taskdes ||
                            !setEquals(
                              selectedTags.toSet(),
                              originalTagsSnapshot.toSet(),
                            ) ||
                            isChecked != originalCompleted;
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
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setModalState(() {});
                                      },
                                      style: TextStyle(color: textColor),
                                      controller: tasknamecontroller,
                                      decoration: InputDecoration(
                                        hintText: 'Task Title',
                                        labelStyle: TextStyle(color: textColor),
                                        hintStyle: TextStyle(color: textColor),
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
                                    ),
                                  ),
                                  Checkbox(
                                    activeColor: foregroundColor,
                                    checkColor: backgroundColor,
                                    side: BorderSide(color: borderColor),
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
                                onChanged: (value) {
                                  setModalState(() {});
                                },
                                style: TextStyle(color: Color(0xFFE9DDFF)),
                                controller: taskdescontroller,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Task description',
                                  labelStyle: TextStyle(color: textColor),
                                  hintStyle: TextStyle(color: textColor),
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

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Select Tags',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),

                              Align(
                                alignment: AlignmentGeometry.topStart,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    spacing: 8,
                                    children: taskProvider.availableTags.map((
                                      tag,
                                    ) {
                                      final tagName = tag['tag_name'] as String;

                                      return FilterChip(
                                        selectedColor: foregroundColor,
                                        checkmarkColor: backgroundColor,
                                        labelStyle: TextStyle(color: textColor),
                                        backgroundColor: backgroundColor,
                                        label: Text(tagName),
                                        selected: selectedTags.contains(
                                          tagName,
                                        ),
                                        onSelected: (selected) {
                                          setModalState(() {
                                            if (selected) {
                                              if (!selectedTags.contains(
                                                tagName,
                                              )) {
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
                                      style: TextStyle(color: textColor),
                                      controller: tagcontroller,
                                      decoration: InputDecoration(
                                        hintText: 'Create new tag',
                                        labelStyle: TextStyle(color: textColor),
                                        hintStyle: TextStyle(color: textColor),
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
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: foregroundColor,
                                    ),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
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
                                        labelStyle: TextStyle(color: textColor),
                                        backgroundColor: backgroundColor,
                                        side: BorderSide(
                                          color: foregroundColor,
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
                              ),

                              SizedBox(height: 16),

                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: foregroundColor,
                                    foregroundColor: backgroundColor,
                                    disabledBackgroundColor: backgroundColor,
                                    disabledForegroundColor: Colors.white54,
                                  ),
                                  onPressed: !hasChanges
                                      ? null
                                      : () async {
                                          await editFunction(
                                            widget.id,
                                            tasknamecontroller.text.trim(),
                                            taskdescontroller.text.trim(),
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
                                  child: Text('Edit Task'),
                                ),
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
              color: Color(0xFFFF8A8A),
              onPressed: () {
                deleteTask();
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
