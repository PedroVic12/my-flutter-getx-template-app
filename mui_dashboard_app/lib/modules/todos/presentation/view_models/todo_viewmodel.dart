import 'package:flutter/material.dart';
import 'package:mui_dashboard_app/modules/todos/application/use_cases/todo_usecases.dart';
import 'package:mui_dashboard_app/modules/todos/domain/entities/todo.dart';

class TodoViewModel extends ChangeNotifier {
  final TodoUseCases _todoUseCases;

  TodoViewModel(this._todoUseCases);

  List<Todo> get todos => _todoUseCases.getAllTodos();

  void addTodo(String title) {
    _todoUseCases.addTodo(title);
    notifyListeners();
  }

  void toggleTodoStatus(String id) {
    try {
      _todoUseCases.toggleTodoStatus(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Todo with ID $id not found: $e');
    }
  }

  void updateTodoTitle(String id, String newTitle) {
    try {
      _todoUseCases.updateTodoTitle(id, newTitle);
      notifyListeners();
    } catch (e) {
      debugPrint('Todo with ID $id not found: $e');
    }
  }

  void deleteTodo(String id) {
    _todoUseCases.deleteTodo(id);
    notifyListeners();
  }

  // Dashboard metrics
  int get totalTodos => todos.length;
  int get completedTodos => todos.where((t) => t.isCompleted).length;
  int get pendingTodos => totalTodos - completedTodos;
}
