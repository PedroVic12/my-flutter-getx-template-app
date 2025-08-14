// CONTROLLER: Backend (Repository)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gohan_treinamentos_app/domain/models/todo_model.dart';
import 'package:gohan_treinamentos_app/domain/repository/todo_repository.dart';

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
