import 'package:flutter/material.dart';

// MODEL
class Todo {
  int id;
  String title;
  bool done;
  Todo({required this.id, required this.title, this.done = false});
}

// TODO APP - Clean Architecture with MVC, Dark Mode, and Drawer Menu

/// 3:10 models -> Bloc -> SetState -> Page -> App

// CONTROLLER
class TodoController extends ChangeNotifier {
  final List<Todo> _todos = [];
  int _nextId = 1;

  List<Todo> get todos => List.unmodifiable(_todos);

  void addTodo(String title) {
    _todos.add(Todo(id: _nextId++, title: title));
    notifyListeners();
  }

  void toggleDone(int id) {
    final todo = _todos.firstWhere((t) => t.id == id);
    todo.done = !todo.done;
    notifyListeners();
  }

  void removeTodo(int id) {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void editTodo(int id, String newTitle) {
    final todo = _todos.firstWhere((t) => t.id == id);
    todo.title = newTitle;
    notifyListeners();
  }
}

// VIEW
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TodoController _controller = TodoController();
  ThemeMode _themeMode = ThemeMode.light;
  int _selectedPage = 0;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPage = index;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Todo MVC App',
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
          themeMode: _themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Todo MVC App'),
              actions: [
                IconButton(
                  icon: Icon(
                    _themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  onPressed: _toggleTheme,
                  tooltip: 'Alternar tema',
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                children: [
                  const DrawerHeader(
                    child: Text('Menu', style: TextStyle(fontSize: 24)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Todos'),
                    selected: _selectedPage == 0,
                    onTap: () => _selectPage(0),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Sobre'),
                    selected: _selectedPage == 1,
                    onTap: () => _selectPage(1),
                  ),
                ],
              ),
            ),
            body: _selectedPage == 0
                ? TodoPage(controller: _controller)
                : const AboutPage(),
          ),
        );
      },
    );
  }
}

// Todo Page
class TodoPage extends StatefulWidget {
  final TodoController controller;
  const TodoPage({super.key, required this.controller});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _textController = TextEditingController();
  int? _editingId;

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    if (_editingId == null) {
      widget.controller.addTodo(text);
    } else {
      widget.controller.editTodo(_editingId!, text);
      _editingId = null;
    }
    _textController.clear();
    setState(() {});
  }

  void _startEdit(Todo todo) {
    _textController.text = todo.title;
    _editingId = todo.id;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final todos = widget.controller.todos;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: _editingId == null
                        ? 'Nova tarefa'
                        : 'Editar tarefa',
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              IconButton(
                icon: Icon(_editingId == null ? Icons.add : Icons.save),
                onPressed: _submit,
                tooltip: _editingId == null ? 'Adicionar' : 'Salvar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('Nenhuma tarefa.'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, i) {
                      final todo = todos[i];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.done,
                            onChanged: (_) =>
                                widget.controller.toggleDone(todo.id),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _startEdit(todo),
                                tooltip: 'Editar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    widget.controller.removeTodo(todo.id),
                                tooltip: 'Remover',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Exemplo de Todo App com CRUD, menu lateral, MVC e dark mode.\nFeito com Flutter.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
