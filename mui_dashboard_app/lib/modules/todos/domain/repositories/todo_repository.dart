import 'package:mui_dashboard_app/modules/todos/domain/entities/todo.dart';

abstract class ITodoRepository {
  List<Todo> getAllTodos();
  void addTodo(Todo todo);
  void updateTodo(Todo todo);
  void deleteTodo(String id);
}
