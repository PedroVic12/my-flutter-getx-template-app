// REPOSITORY (agora usando um Map interno)
import '../models/todo_model.dart';

class TodoRepository {
  final Map<int, TodoModel> _todos = {
    // DONE
    1: TodoModel(
      id: 1,
      title: 'Apresentação e diário para Terapia',
      note: 'Shotcut com vídeos engraçados',
      done: true,
      status: 'DONE',
      xp: 10,
    ),
    2: TodoModel(
      id: 2,
      title: 'Estudos de simuladores com Pandapower, AnaRede e deck EDITCEPEEL',
      done: true,
      status: 'DONE',
      xp: 15,
    ),
    3: TodoModel(
      id: 3,
      title: 'Refatoração do deck de controle de tensão 16 barras',
      done: true,
      status: 'DONE',
      xp: 15,
    ),
    4: TodoModel(
      id: 4,
      title: 'Alteração no deck com DBSH e FBAN para barras SHUNT',
      done: true,
      status: 'DONE',
      xp: 15,
    ),
    5: TodoModel(
      id: 5,
      title: 'Estudo dos Casos de cenários 2025 - SIN',
      note: 'Planilha + deck',
      done: true,
      status: 'DONE',
      xp: 15,
    ),
    6: TodoModel(
      id: 6,
      title: 'Refazer provas de circuitos digitais, CC e CA',
      done: true,
      status: 'DONE',
      xp: 10,
    ),
    7: TodoModel(
      id: 7,
      title: 'Alteração no fluxo SUL de 3879 para 6000 na planilha FLOW',
      note: 'Análise da Barra 501, ajuste de bacias, geração de novo deck',
      done: true,
      status: 'DONE',
      xp: 20,
    ),
    8: TodoModel(
      id: 8,
      title: 'Confirmar com Alexandre análise AnaREDE + conceitos SEP',
      done: true,
      status: 'DONE',
      xp: 10,
    ),

    // IN PROGRESS
    9: TodoModel(
      id: 9,
      title: 'Configura → Despacho → Cenário → deck',
      status: 'IN_PROGRESS',
      xp: 15,
    ),
    10: TodoModel(
      id: 10,
      title: 'Reduzir carga do SUL para 20.129 MW e redistribuir SE',
      note: 'Planilha FLOW - tentar colocar 6000 KV',
      status: 'IN_PROGRESS',
      xp: 20,
    ),
    11: TodoModel(
      id: 11,
      title: 'Estudos de frontend com Astro, React e Flutter',
      status: 'IN_PROGRESS',
      xp: 15,
    ),
    12: TodoModel(
      id: 12,
      title: 'Sistemas CRUD + API Python (Flask, FastAPI, Docker)',
      status: 'IN_PROGRESS',
      xp: 15,
    ),
    13: TodoModel(
      id: 13,
      title: 'Blog Astro + templates HTML + deploy',
      status: 'IN_PROGRESS',
      xp: 10,
    ),
    14: TodoModel(
      id: 14,
      title: 'Preparação para Ciclo Jedi Cyberpunk',
      note: 'Provas + simulações + automações com N8N',
      status: 'IN_PROGRESS',
      xp: 20,
    ),

    // TODO
    15: TodoModel(id: 15, title: 'TAREFAS ONS', status: 'TODO', xp: 10),
    16: TodoModel(
      id: 16,
      title: 'ENGENHARIA ELÉTRICA UFF',
      status: 'TODO',
      xp: 10,
    ),
    17: TodoModel(
      id: 17,
      title: 'ARTIGO CIENTÍFICO PIBIC UFF',
      status: 'TODO',
      xp: 15,
    ),
    18: TodoModel(
      id: 18,
      title: 'Modelagem e análise de sistemas elétricos de potência',
      status: 'TODO',
      xp: 20,
    ),
    19: TodoModel(
      id: 19,
      title: 'PROGRAMAÇÃO FRONTEND',
      status: 'TODO',
      xp: 15,
    ),
    20: TodoModel(id: 20, title: 'PROGRAMAÇÃO BACKEND', status: 'TODO', xp: 15),
    21: TodoModel(
      id: 21,
      title: 'IoT com Arduino + WebSocket + HTML + séries temporais',
      status: 'TODO',
      xp: 20,
    ),
    22: TodoModel(
      id: 22,
      title: 'ML com dataset ENERGY (classificação, regressão, KMeans)',
      status: 'TODO',
      xp: 20,
    ),
    23: TodoModel(
      id: 23,
      title: 'UFF: Modelagem de circuitos digitais + CC/CA + Arduino',
      status: 'TODO',
      xp: 15,
    ),
    24: TodoModel(
      id: 24,
      title: 'Estudos de potência elétrica e equações base',
      note: '- Potência Ativa / Reativa / Aparente\n- Conceitos de CA',
      status: 'TODO',
      xp: 15,
    ),
    25: TodoModel(
      id: 25,
      title: 'Análise de contingência com Pandapower',
      status: 'TODO',
      xp: 15,
    ),
    26: TodoModel(
      id: 26,
      title: 'Testar classe RedeElétrica + otimização com AG',
      status: 'TODO',
      xp: 20,
    ),
    27: TodoModel(
      id: 27,
      title: 'RCE Web App: Configurador e testes de velocidade',
      status: 'TODO',
      xp: 20,
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
