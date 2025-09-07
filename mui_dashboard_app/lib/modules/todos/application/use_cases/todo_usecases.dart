import 'package:flutter/foundation.dart';
import 'package:mui_dashboard_app/modules/todos/domain/entities/todo.dart';
import 'package:mui_dashboard_app/modules/todos/domain/repositories/todo_repository.dart';

class TodoUseCases {
  final ITodoRepository _repository;

  TodoUseCases(this._repository);

  List<Todo> getAllTodos() => _repository.getAllTodos();

  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
    );
    _repository.addTodo(todo);
  }

  void toggleTodoStatus(String id) {
    final todos = _repository.getAllTodos();
    final todo = todos.firstWhere((t) => t.id == id);
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    _repository.updateTodo(updatedTodo);
  }

  void updateTodoTitle(String id, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final todos = _repository.getAllTodos();
    final todo = todos.firstWhere((t) => t.id == id);
    final updatedTodo = todo.copyWith(title: newTitle.trim());
    _repository.updateTodo(updatedTodo);
  }

  void deleteTodo(String id) {
    _repository.deleteTodo(id);
  }
}
