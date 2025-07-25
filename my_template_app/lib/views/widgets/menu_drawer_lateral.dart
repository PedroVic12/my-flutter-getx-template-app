// MENU DRAWER
import 'package:flutter/material.dart';
import 'package:my_template_app/views/pages/financial_app_controlefinanceiro.dart';
import 'package:my_template_app/views/pages/todo_list_page.dart';
import 'package:my_template_app/views/template/kanban_board.dart';

import '../../domain/controllers/backend_controller.dart';

final List<Map<String, dynamic>> appPages = [
  {'title': 'Lista de Tarefas', 'icon': Icons.list, 'widget': const TodoPage()},
  {'title': 'Sobre', 'icon': Icons.info, 'widget': const AboutPage()},
  {
    'title': 'Kanban Board',
    'icon': Icons.settings,
    'widget': const KanbanProApp(),
  },
  {
    'title': 'Controle Financeiro',
    'icon': Icons.money,
    'widget': const FinancialHomePage(),
  },
  // Adicione mais páginas aqui se quiser
];

final todoController = TodoBackendController();

//final result = todoController.fetchTodos();
//print(result);

class MenuDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;
  final List<Map<String, dynamic>> pages;

  const MenuDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text(
              'Menu Lateral de Navegação Flutter',
              style: TextStyle(fontSize: 24),
            ),
          ),
          ...pages.asMap().entries.map((entry) {
            final idx = entry.key;
            final page = entry.value;
            return ListTile(
              leading: Icon(page['icon']),
              title: Text(page['title']),
              selected: selectedIndex == idx,
              onTap: () {
                onSelect(idx);
                Navigator.of(context).pop();
              },
            );
          }),
        ],
      ),
    );
  }
}
