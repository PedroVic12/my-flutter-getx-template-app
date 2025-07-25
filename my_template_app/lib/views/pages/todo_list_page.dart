// HOME PAGE
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:my_template_app/domain/controllers/backend_controller.dart';

import '../../domain/models/todo_model.dart';
import '../widgets/menu_drawer_lateral.dart';

class TodoListHomePage extends StatelessWidget {
  const TodoListHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final ui = Get.find<UIStateController>();
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Todo GetX MVC App + Dart Vaden Controller -> Crud Sqlite',
          ),
          actions: [
            IconButton(
              icon: Icon(
                ui.themeMode.value == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: ui.toggleTheme,
              tooltip: 'Alternar tema',
            ),
          ],
        ),
        drawer: MenuDrawer(
          selectedIndex: ui.selectedPage.value,
          onSelect: (index) => ui.selectedPage.value = index,
          pages: appPages,
        ),
        body: appPages[ui.selectedPage.value]['widget'],
      ),
    );
  }
}

// TODO PAGE
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final backend = Get.find<TodoBackendController>();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    backend.fetchTodos();
  }

  void _showEditModal(TodoModel todo) {
    final titleController = TextEditingController(text: todo.title);
    final noteController = TextEditingController(text: todo.note);

    // Função para atualizar os checkboxes do markdown
    void _toggleCheckbox(int idx, bool checked) {
      final lines = noteController.text.split('\n');
      if (idx < 0 || idx >= lines.length) return;
      final line = lines[idx];
      if (line.contains('- [ ]')) {
        lines[idx] = line.replaceFirst('- [ ]', '- [x]');
      } else if (line.contains('- [x]')) {
        lines[idx] = line.replaceFirst('- [x]', '- [ ]');
      }
      noteController.text = lines.join('\n');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Editar Tarefa'),
          content: SizedBox(
            width: 800,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Editor
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Título'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Nota (Markdown)',
                        ),
                        maxLines: 6,
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Preview com checkboxes interativos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preview Markdown:'),
                      Container(
                        height: 500,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView(
                          children: [
                            ...noteController.text
                                .split('\n')
                                .asMap()
                                .entries
                                .map((entry) {
                                  final idx = entry.key;
                                  final line = entry.value;
                                  final checkboxMatch = RegExp(
                                    r'- \[( |x)\] (.*)',
                                  ).firstMatch(line);
                                  if (checkboxMatch != null) {
                                    final checked =
                                        checkboxMatch.group(1) == 'x';
                                    final text = checkboxMatch.group(2) ?? '';
                                    return CheckboxListTile(
                                      value: checked,
                                      title: Text(text),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      onChanged: (val) {
                                        _toggleCheckbox(idx, val ?? false);
                                        setModalState(() {});
                                      },
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: MarkdownBody(data: line),
                                    );
                                  }
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                todo.title = titleController.text;
                todo.note = noteController.text;
                await backend.updateTodo(todo);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: 'Nova tarefa'),
                    autocorrect: true,
                    autofocus: true,
                    style: TextStyle(fontSize: 16.0),
                    onSubmitted: (_) async {
                      if (_textController.text.trim().isNotEmpty) {
                        await backend.addTodo(_textController.text.trim());
                        _textController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (_textController.text.trim().isNotEmpty) {
                      await backend.addTodo(_textController.text.trim());
                      _textController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: backend.todos.isEmpty
                  ? const Center(child: Text('Nenhuma tarefa ainda. :( '))
                  : ListView.builder(
                      itemCount: backend.todos.length,
                      itemBuilder: (context, i) {
                        final todo = backend.todos[i];
                        return Card(
                          color: Colors.amber[900],
                          child: ListTile(
                            leading: Checkbox(
                              value: todo.done,
                              onChanged: (_) async {
                                todo.done = !todo.done;
                                await backend.updateTodo(todo);
                              },
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: todo.note.isNotEmpty
                                ? MarkdownBody(data: todo.note)
                                : null,
                            onTap: () => _showEditModal(todo),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => backend.deleteTodo(todo.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ABOUT PAGE
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Exemplo de Todo App para estudante e programador de Eng. Elétrica.\nCRUD, menu lateral, MVC, GetX, dark mode.\nNotas em Markdown com checkboxes interativos no preview.',
          textAlign: TextAlign.center,
        ),

        Text("\n\n"),

        Text(
          'Ainda falta implementar Sqlite, LocalStorage com Controllador Separado.\nOrganizar arquivos e refatoração com testes unitarios.\nConstruçao do CRUD completo com resposta na API url.\nBuilderListView, OBS, UseState com GetX para meu aplicativo',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
