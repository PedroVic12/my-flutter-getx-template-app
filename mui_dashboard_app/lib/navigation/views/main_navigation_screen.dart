import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mui_dashboard_app/common/theme/view_models/theme_viewmodel.dart';
import 'package:mui_dashboard_app/modules/dashboard/views/dashboard_screen.dart';
import 'package:mui_dashboard_app/modules/products/presentation/view_models/product_viewmodel.dart';
import 'package:mui_dashboard_app/modules/products/presentation/widgets/dialogs/add_product_dialog.dart';
import 'package:mui_dashboard_app/modules/products/presentation/views/stock_control_screen.dart';
import 'package:mui_dashboard_app/modules/todos/presentation/view_models/todo_viewmodel.dart';
import 'package:mui_dashboard_app/modules/todos/presentation/widgets/dialogs/add_todo_dialog.dart';
import 'package:mui_dashboard_app/modules/todos/presentation/views/todo_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<String> _pageTitles = ['Dashboard', 'Todo List', 'Stock Control'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AddTodoDialog(
        onAdd: (title) {
          context.read<TodoViewModel>().addTodo(title);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AddProductDialog(
        onAdd: (name, quantity) {
          context.read<ProductViewModel>().addProduct(name, quantity);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        actions: [
          Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, child) {
              return IconButton(
                icon: Icon(
                  themeViewModel.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: themeViewModel.toggleTheme,
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.check_box),
              title: const Text('Todo List'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Stock Control'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardScreen(),
          TodoListScreen(),
          StockControlScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddTodoDialog(context),
              child: const Icon(Icons.add),
            )
          : _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () => _showAddProductDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
