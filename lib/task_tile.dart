import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'package:todo/shared/functions.dart';

import 'models/task.dart';
import 'models/tasks_data.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final TasksData tasksData;

  const TaskTile({Key? key, required this.task, required this.tasksData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.done ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          formatDate(task.dueDate),
          style: TextStyle(
            decoration:
                task.done ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        onTap: () => Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => TaskDetailScreen(taskData: task),
        )),
        leading: Checkbox(
          value: task.done,
          onChanged: (checkbox) {
            tasksData.updateTaskProgress(task);
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            tasksData.deleteTask(task);
          },
        ),
      ),
    );
  }
}
