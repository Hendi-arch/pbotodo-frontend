import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:todo/Services/database_service.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/tasks_data.dart';
import 'package:todo/screens/feedback_screen.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'package:todo/services/shared_pref_service.dart';

import '../task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sharedPrefService = SharedPrefService();

  List<Task>? tasks;
  final _showCaseAddTaskButton = GlobalKey();
  final _showCaseLogoutButton = GlobalKey();
  final _showCaseFeedbackButton = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
    super.initState();
  }

  void _onInit() async {
    await _getTasks(context.read<TasksData>());
    if (tasks != null) {
      _checkShowCase();
    }
  }

  void _checkShowCase() async {
    bool test1 = await _sharedPrefService.getShowCaseAddTaskButtonKey();
    bool test2 = await _sharedPrefService.getShowCasLogoutButtonKey();
    bool test3 = await _sharedPrefService.getShowCasFeedbackButtonKey();
    if (!test1 && !test2 && !test3) {
      // ignore: use_build_context_synchronously
      ShowCaseWidget.of(context).startShowCase([
        _showCaseLogoutButton,
        _showCaseFeedbackButton,
        _showCaseAddTaskButton
      ]);
    }
    _sharedPrefService.setShowCaseAddTaskButtonKey(true);
    _sharedPrefService.setShowCaseLogoutButtonKey(true);
    _sharedPrefService.setShowCaseFeedbackButtonKey(true);
  }

  Future<void> _getTasks(TasksData tasksData) async {
    tasks = await DatabaseService().getTasks();
    tasksData.tasks = tasks!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo Tasks (${Provider.of<TasksData>(context).tasks.length})',
        ),
        centerTitle: true,
        actions: [
          Showcase(
            key: _showCaseLogoutButton,
            title: 'Logout',
            description: 'Tap here to logout from your account',
            child: IconButton(
              onPressed: () => context.read<TasksData>().logout(context),
              icon: const Icon(Icons.logout_outlined),
            ),
          ),
          Showcase(
            key: _showCaseFeedbackButton,
            title: 'Feedback',
            description: 'Tap here to give a feedback to our app.',
            child: IconButton(
              onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => const FeedbackScreen())),
              icon: const Icon(Icons.feedback_outlined),
            ),
          )
        ],
      ),
      body: tasks == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
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
                    },
                  );
                },
              ),
            ),
      floatingActionButton: Showcase(
        key: _showCaseAddTaskButton,
        title: 'Add Task',
        description: 'Tap here to add your task',
        targetPadding: const EdgeInsets.all(4).w,
        targetShapeBorder: const CircleBorder(),
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => const TaskDetailScreen(),
          )),
        ),
      ),
    );
  }
}
