import 'package:todo/models/task.dart';

extension TaskListExtension on List<Task> {
  void updateWhere({required int id, required Task updatedTask}) {
    final index = indexWhere((task) => task.id == id);
    if (index != -1) {
      this[index] = updatedTask;
    }
  }
}
