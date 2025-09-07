import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mui_dashboard_app/modules/todos/domain/entities/todo.dart';
import 'package:mui_dashboard_app/modules/todos/presentation/view_models/todo_viewmodel.dart';
import 'package:mui_dashboard_app/modules/todos/presentation/widgets/dialogs/edit_todo_dialog.dart';

class TodoItemWidget extends StatelessWidget {
  final Todo todo;

  const TodoItemWidget({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<TodoViewModel>().deleteTodo(todo.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${todo.title}" dismissed')));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (newValue) {
              if (newValue != null) {
                context.read<TodoViewModel>().toggleTodoStatus(todo.id);
              }
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isCompleted ? Colors.grey : null,
            ),
          ),
          onTap: () => _showEditTodoDialog(context, todo),
        ),
      ),
    );
  }

  void _showEditTodoDialog(BuildContext context, Todo todo) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => EditTodoDialog(
        todo: todo,
        onEdit: (newTitle) {
          context.read<TodoViewModel>().updateTodoTitle(todo.id, newTitle);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}
