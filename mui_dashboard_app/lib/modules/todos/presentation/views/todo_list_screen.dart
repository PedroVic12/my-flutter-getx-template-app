import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mui_dashboard_app/modules/todos/presentation/view_models/todo_viewmodel.dart';
import 'package:mui_dashboard_app/modules/todos/presentation/widgets/todo_item.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, todoViewModel, child) {
        if (todoViewModel.todos.isEmpty) {
          return const Center(child: Text('No tasks yet! Add a new one.'));
        }
        return ListView.builder(
          itemCount: todoViewModel.todos.length,
          itemBuilder: (context, index) {
            final todo = todoViewModel.todos[index];
            return TodoItemWidget(todo: todo);
          },
        );
      },
    );
  }
}
