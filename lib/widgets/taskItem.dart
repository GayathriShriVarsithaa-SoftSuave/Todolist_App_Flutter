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
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.completed == 1;
  }

  @override
  void didUpdateWidget(covariant TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.completed != widget.completed) {
      isChecked = widget.completed == 1;
    }
  }
  Future<void> changeCompletedStatus(bool value) async {
    await context.read<TaskProvider>().changeCompletedStatus(
      id: widget.id,
      taskname: widget.taskname,
      taskdes: widget.taskdes,
      createdAt: widget.createdAt,
      completed: value,
    );
  }

  Future<void> deleteTask() async {
    await context.read<TaskProvider>().deleteTask(widget.id);
  }

  Future<void> editInfo() async {
    // showModalBottomSheet(
    //   context: context,
    //   builder: (context) {
    //     return ();
    //   },
    // );
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
            onPressed: () {
              editInfo();
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
