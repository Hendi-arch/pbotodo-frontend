import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/extensions/task_data_extension.dart';
import 'package:todo/screens/auth_screen.dart';
import 'package:todo/Services/database_service.dart';
import 'package:todo/models/task.dart';

class TasksData extends ChangeNotifier {
  List<Task> tasks = [];

  Future<void> addTask(Task taskData) async {
    Task task = await DatabaseService().addTask(taskData);
    tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task taskData) async {
    Task task = await DatabaseService().updateTask(taskData);
    tasks.updateWhere(id: task.id!, updatedTask: task);
    notifyListeners();
  }

  void updateTaskProgress(Task task) {
    task.toggle();
    DatabaseService().updateTaskProgress(task.id!);
    notifyListeners();
  }

  void deleteTask(Task task) {
    tasks.remove(task);
    DatabaseService().deleteTask(task.id!);
    notifyListeners();
  }

  void logout(BuildContext context) async {
    try {
      await DatabaseService().logout();
      tasks.clear();

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const AuthScreen()));
    } catch (e) {
      debugPrint(e.toString());
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oops, An error occurred, please try again'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }
}
