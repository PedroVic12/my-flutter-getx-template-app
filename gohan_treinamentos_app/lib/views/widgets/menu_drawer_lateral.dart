import 'package:flutter/material.dart';
import 'package:gohan_treinamentos_app/views/pages/financial_app_controlefinanceiro.dart';
import 'package:gohan_treinamentos_app/views/pages/productivity_crud_page.dart'; // Updated import
import 'package:gohan_treinamentos_app/views/pages/kanban_page.dart'; // Updated import

import '../../domain/controllers/backend_controller.dart';

final List<Map<String, dynamic>> appPages = [
  {'title': 'Lista de Tarefas', 'icon': Icons.list, 'widget': const ProductivityTodoPage()}, // Updated widget
  {'title': 'Sobre', 'icon': Icons.info, 'widget': const ProductivityAboutPage()}, // Updated widget
  {
    'title': 'Kanban Board',
    'icon': Icons.view_kanban, // Changed icon to view_kanban
    'widget': const KanbanProApp(),
  },
  {
    'title': 'Controle Financeiro',
    'icon': Icons.money,
    'widget': const FinancialHomePage(),
  },
  // Adicione mais páginas aqui se quiser
];

// Removed final todoController = TodoBackendController();
// Removed //final result = todoController.fetchTodos();
// Removed //print(result);

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