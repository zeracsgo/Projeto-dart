class Task {
  final String id;
  String title;
  bool completed;
  final DateTime date;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
        'date': date.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        completed: json['completed'],
        date: DateTime.parse(json['date']),
      );
}
