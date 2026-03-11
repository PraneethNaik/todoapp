class TodoModel {
  final String id;
  final String title;
  final bool isDone;
  final String userId;
  final DateTime? dueDate;

  TodoModel({
    required this.id,
    required this.title,
    required this.isDone,
    required this.userId,
    this.dueDate,
  });
}
