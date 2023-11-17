import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 1)
class TodoModel {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? todoText;
  @HiveField(2)
  bool isDone;

  TodoModel({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });
  static List<TodoModel> todoList() {
    return [];
  }
}
