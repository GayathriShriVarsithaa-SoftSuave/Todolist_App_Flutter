import './../../../services/toast_msg.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './../../../providers/task_provider.dart';
import 'package:provider/provider.dart';


Future<bool> insertTasktodb(BuildContext context, TextEditingController tasknamecontroller, TextEditingController taskdetailscontroller,List<String> selectedTags) async {
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
  showToastMsg('Added', Colors.green, Toast.LENGTH_LONG);

  return true;
}
