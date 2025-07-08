// REPOSITORY (agora usando um Map interno)
import '../models/todo_model.dart';

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
