// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/tasks_data.dart';
import 'package:provider/provider.dart';
import 'package:todo/shared/functions.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? taskData;

  const TaskDetailScreen({super.key, this.taskData});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _todoTitleController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  String _reminder = 'at_time_notification_channel_id';
  String _urgency = 'not_important_notification_channel_id';
  bool _isFetchingData = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isFetchingData = true);
    try {
      if (_dueDate.isBefore(DateTime.now())) {
        FocusScope.of(context).unfocus();
        setState(() => _isFetchingData = false);
        _showSnackBar("Due date must be a date in the future.");
        return;
      }
      if (widget.taskData == null) {
        await context.read<TasksData>().addTask(
              Task(
                title: _todoTitleController.text,
                dueDate: _dueDate,
                notificationChannelId: _reminder,
                urgency: _urgency,
              ),
            );
        _showSnackBar('Task added successfully');
        Navigator.pop(context); // Navigate back to previous page
      } else {
        final updatedTask = Task(
          id: widget.taskData!.id,
          title: _todoTitleController.text,
          dueDate: _dueDate,
          notificationChannelId: _reminder,
          urgency: _urgency,
          createdAt: widget.taskData!.createdAt,
        );
        await context.read<TasksData>().updateTask(updatedTask);
        _showSnackBar('Task updated successfully');
      }
    } catch (e) {
      debugPrint(e.toString());
      _showSnackBar('Oops, an error occurred. Please try again.');
    } finally {
      if (mounted) {
        FocusScope.of(context).unfocus();
        setState(() => _isFetchingData = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _initForm() {
    if (widget.taskData != null) {
      _todoTitleController.text = widget.taskData!.title;
      _dueDate = widget.taskData!.dueDate;
      _reminder = widget.taskData!.notificationChannelId;
      _urgency = widget.taskData!.urgency;
    }
  }

  @override
  void initState() {
    _initForm();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0).w,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _todoTitleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1.0.w,
                  ),
                  borderRadius: BorderRadius.circular(4.0).w,
                ),
                child: ListTile(
                  title: const Text('Due date'),
                  subtitle: Text(formatDate(_dueDate, 'd MMM, y')),
                  onTap: () async {
                    final DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _dueDate = _dueDate.copyWith(
                          day: selectedDate.day,
                          month: selectedDate.month,
                          year: selectedDate.year,
                          second: 0,
                          minute: _dueDate.minute,
                          hour: _dueDate.hour,
                        );
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 16.0.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1.0.w,
                  ),
                  borderRadius: BorderRadius.circular(4.0).w,
                ),
                child: ListTile(
                  title: const Text('Due date time'),
                  subtitle: Text(formatDate(_dueDate, 'hh:mm:ss a')),
                  onTap: () async {
                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_dueDate),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _dueDate = _dueDate.copyWith(
                          day: _dueDate.day,
                          month: _dueDate.month,
                          year: _dueDate.year,
                          second: 0,
                          minute: selectedTime.minute,
                          hour: selectedTime.hour,
                        );
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 16.0.h),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Reminder',
                  border: OutlineInputBorder(),
                ),
                value: _reminder,
                items: const [
                  DropdownMenuItem(
                    value: 'at_time_notification_channel_id',
                    child: Text('At the time of the event'),
                  ),
                  DropdownMenuItem(
                    value: 'five_minutes_before_notification_channel_id',
                    child: Text('5 minutes before'),
                  ),
                  DropdownMenuItem(
                    value: 'ten_minutes_before_notification_channel_id',
                    child: Text('10 minutes before'),
                  ),
                  DropdownMenuItem(
                    value: 'fifteen_minutes_before_notification_channel_id',
                    child: Text('15 minutes before'),
                  ),
                  DropdownMenuItem(
                    value: 'thirty_minutes_before_notification_channel_id',
                    child: Text('30 minutes before'),
                  ),
                  DropdownMenuItem(
                    value: 'one_hour_before_notification_channel_id',
                    child: Text('1 hour before'),
                  ),
                  DropdownMenuItem(
                    value: 'two_hours_before_notification_channel_id',
                    child: Text('2 hours before'),
                  ),
                  DropdownMenuItem(
                    value: 'one_day_before_notification_channel_id',
                    child: Text('1 day before'),
                  ),
                  DropdownMenuItem(
                    value: 'two_days_before_notification_channel_id',
                    child: Text('2 days before'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _reminder = value!;
                  });
                },
              ),
              SizedBox(height: 16.0.h),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Urgency',
                  border: OutlineInputBorder(),
                ),
                value: _urgency,
                items: const [
                  DropdownMenuItem(
                    value: 'not_important_notification_channel_id',
                    child: Text('Not Important'),
                  ),
                  DropdownMenuItem(
                    value: 'important_notification_channel_id',
                    child: Text('Important'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _urgency = value!;
                  });
                },
              ),
              SizedBox(height: 16.0.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    child: child,
                  );
                },
                child: _isFetchingData
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Save'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
