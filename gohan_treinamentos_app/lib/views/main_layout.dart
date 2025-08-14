import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gohan_treinamentos_app/controllers/theme_controller.dart';
import 'package:gohan_treinamentos_app/views/widgets/menu_drawer_lateral.dart'; // Import appPages

class MainLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const MainLayout({Key? key, required this.title, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: themeController.toggleTheme,
            tooltip: 'Alternar tema',
          )),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Dynamically generate ListTiles from appPages
            ...appPages.asMap().entries.map((entry) {
              final idx = entry.key;
              final page = entry.value;
              return ListTile(
                leading: Icon(page['icon']),
                title: Text(page['title']),
                onTap: () {
                  // Navigate based on the page title or a defined route name
                  // Assuming a simple mapping for now, adjust if your routing is more complex
                  String routeName;
                  if (page['title'] == 'Lista de Tarefas') {
                    routeName = '/productivity';
                  } else if (page['title'] == 'Kanban Board') {
                    routeName = '/kanban';
                  } else if (page['title'] == 'Controle Financeiro') {
                    routeName = '/money'; // Assuming you have a route for this
                  } else {
                    routeName = '/gohan'; // Default or other pages
                  }
                  Get.toNamed(routeName);
                  Get.back(); // Close the drawer
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: child,
    );
  }
}