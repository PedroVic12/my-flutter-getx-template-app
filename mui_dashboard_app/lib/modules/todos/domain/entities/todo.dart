import 'package:mui_dashboard_app/common/entities/entity.dart';

class Todo extends Entity {
  String title;
  bool isCompleted;

  Todo({required String id, required this.title, this.isCompleted = false})
    : super(id: id);

  Todo copyWith({String? title, bool? isCompleted}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}