import 'package:flutter/cupertino.dart';
import 'package:todo/extensions/task_data_extension.dart';
import 'package:todo/screens/auth_screen.dart';
import 'package:todo/Services/database_service.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/shared_pref_service.dart';

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
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      tasks.clear();
      await SharedPrefService().removeCredentials();

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const AuthScreen()));
    }
  }
}
