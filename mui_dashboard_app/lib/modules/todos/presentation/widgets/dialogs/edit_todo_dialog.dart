import 'package:flutter/material.dart';
import 'package:mui_dashboard_app/modules/todos/domain/entities/todo.dart';

class EditTodoDialog extends StatefulWidget {
  final Todo todo;
  final ValueChanged<String> onEdit;

  const EditTodoDialog({super.key, required this.todo, required this.onEdit});

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter new task title',
          border: OutlineInputBorder(),
        ),
        onSubmitted: widget.onEdit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => widget.onEdit(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
