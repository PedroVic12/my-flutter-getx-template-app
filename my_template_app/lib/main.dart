import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// MODEL
class TodoModel {
  int id;
  String title;
  bool done;
  String note;
  TodoModel({
    required this.id,
    required this.title,
    this.done = false,
    this.note = "",
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'],
    title: json['title'],
    done: json['done'] ?? false,
    note: json['note'] ?? "",
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'done': done,
    'note': note,
  };
}

// REPOSITORY (agora usando um Map interno)
class TodoRepository {
  final Map<int, TodoModel> _todos = {
    1: TodoModel(
      id: 1,
      title: 'Estudar para prova de Circuitos',
      done: false,
      note:
          '- [ ] Revisar teoria\n- [ ] Fazer exercícios\n- [ ] Ver videoaulas',
    ),
    2: TodoModel(
      id: 2,
      title: 'Projeto de Programação',
      done: false,
      note:
          '- [ ] Implementar função objetivo\n- [ ] Testar algoritmo\n- [ ] Escrever relatório',
    ),
    3: TodoModel(
      id: 3,
      title: 'Reunião com grupo de TCC',
      done: false,
      note: '- [ ] Preparar slides\n- [ ] Definir próximos passos',
    ),
    4: TodoModel(
      id: 4,
      title: 'Enviar relatório de estágio',
      done: false,
      note: '- [ ] Revisar texto\n- [ ] Gerar PDF\n- [ ] Enviar por e-mail',
    ),
  };

  int _nextId = 5;

  Future<List<TodoModel>> fetchTodos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _todos.values.toList();
  }

  Future<TodoModel> addTodo(String title) async {
    final todo = TodoModel(id: _nextId++, title: title);
    _todos[todo.id] = todo;
    return todo;
  }

  Future<void> updateTodo(TodoModel todo) async {
    _todos[todo.id] = todo;
  }

  Future<void> deleteTodo(int id) async {
    _todos.remove(id);
  }
}

// CONTROLLER: Backend (Repository)
class TodoBackendController extends GetxController {
  final TodoRepository repo = TodoRepository();
  final todos = <TodoModel>[].obs;

  Future<void> fetchTodos() async {
    try {
      todos.assignAll(await repo.fetchTodos());
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao buscar tarefas');
    }
  }

  Future<void> addTodo(String title) async {
    try {
      final todo = await repo.addTodo(title);
      todos.add(todo);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao adicionar tarefa');
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      await repo.updateTodo(todo);
      int idx = todos.indexWhere((t) => t.id == todo.id);
      if (idx != -1) todos[idx] = todo;
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar tarefa');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await repo.deleteTodo(id);
      todos.removeWhere((t) => t.id == id);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover tarefa');
    }
  }
}

// CONTROLLER: UI State (tema, página, seleção)
class UIStateController extends GetxController {
  var themeMode = ThemeMode.light.obs;
  var selectedPage = 0.obs;

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void selectPage(int idx) => selectedPage.value = idx;
}

// MAIN
void main() {
  Get.put(TodoBackendController());
  Get.put(UIStateController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final ui = Get.find<UIStateController>();
    return Obx(
      () => GetMaterialApp(
        title: 'Todo GetX App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ui.themeMode.value,
        home: const HomePage(),
      ),
    );
  }
}

// HOME PAGE
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final ui = Get.find<UIStateController>();
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text('Todo GetX App'),
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
        drawer: const MenuDrawer(),
        body: ui.selectedPage.value == 0 ? const TodoPage() : const AboutPage(),
      ),
    );
  }
}

// MENU DRAWER
class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final ui = Get.find<UIStateController>();
    return Drawer(
      child: Obx(
        () => ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Todos'),
              selected: ui.selectedPage.value == 0,
              onTap: () {
                ui.selectPage(0);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre'),
              selected: ui.selectedPage.value == 1,
              onTap: () {
                ui.selectPage(1);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
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
            width: 500,
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
                        height: 180,
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
                  ? const Center(child: Text('Nenhuma tarefa.'))
                  : ListView.builder(
                      itemCount: backend.todos.length,
                      itemBuilder: (context, i) {
                        final todo = backend.todos[i];
                        return Card(
                          color: Colors.amber[100],
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
    return const Center(
      child: Text(
        'Exemplo de Todo App para estudante e programador de Eng. Elétrica.\nCRUD, menu lateral, MVC, GetX, dark mode.\nNotas em Markdown com checkboxes interativos no preview.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
