class Task {
  final int? id;
  String title;
  bool done;
  String? username;
  DateTime dueDate;
  String notificationChannelId;
  String urgency;
  final DateTime? createdAt;

  Task({
    this.id,
    required this.title,
    this.done = false,
    this.username,
    required this.dueDate,
    required this.notificationChannelId,
    required this.urgency,
    this.createdAt,
  });

  factory Task.fromMap(Map<String, dynamic> taskMap) {
    return Task(
      id: taskMap['id'],
      title: taskMap['title'],
      done: taskMap['done'],
      username: taskMap['username'],
      dueDate: DateTime.parse(taskMap['dueDate']),
      notificationChannelId: taskMap['notificationChannelId'],
      urgency: taskMap['urgency'],
      createdAt: DateTime.parse(taskMap['createdAt']),
    );
  }

  void toggle() {
    done = !done;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
      'username': username,
      'dueDate': dueDate.toIso8601String(),
      'notificationChannelId': notificationChannelId,
      'urgency': urgency
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'id': id,
      'title': title,
      'done': done,
      'username': username,
      'dueDate': dueDate.toIso8601String(),
      'notificationChannelId': notificationChannelId,
      'urgency': urgency,
      'createdAt': createdAt?.toIso8601String()
    };
  }
}
