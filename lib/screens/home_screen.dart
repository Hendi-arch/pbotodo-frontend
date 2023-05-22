import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:todo/Services/database_service.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/tasks_data.dart';
import 'package:todo/screens/task_detail_screen.dart';

import '../task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task>? tasks;

  void getTasks(TasksData tasksData) async {
    tasks = await DatabaseService().getTasks();
    tasksData.tasks = tasks!;
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getTasks(context.read<TasksData>()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return tasks == null
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'Todo Tasks (${Provider.of<TasksData>(context).tasks.length})',
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () => context.read<TasksData>().logout(context),
                  icon: const Icon(Icons.logout),
                )
              ],
            ),
            body: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
              child: Consumer<TasksData>(
                builder: (context, tasksData, child) {
                  return ListView.builder(
                      itemCount: tasksData.tasks.length,
                      itemBuilder: (context, index) {
                        Task task = tasksData.tasks[index];
                        return TaskTile(
                          task: task,
                          tasksData: tasksData,
                        );
                      });
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const TaskDetailScreen(),
              )),
            ),
          );
  }
}
