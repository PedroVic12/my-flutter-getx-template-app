// src/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_template_app/domain/controllers/backend_controller.dart';
import 'package:my_template_app/views/pages/financial_app_controlefinanceiro.dart';
import 'package:my_template_app/views/pages/my_home_page.dart';
import 'package:my_template_app/views/template/kanban_board.dart';
import 'views/pages/todo_list_page.dart';

// MAIN
void main() {
  Get.put(TodoBackendController());
  Get.put(UIStateController());
  runApp(const MyApp());
}

final temas = [
  ThemeData(
    primarySwatch: Colors.blue,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: const Color(0xFFf1f5f9),
    cardTheme: CardThemeData(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
  ),
  ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 55, 104, 197),
    ),
    useMaterial3: true,
    brightness: Brightness.light,
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = Get.find<UIStateController>();
    return Obx(
      () => GetMaterialApp(
        title: 'My App Template V 3.1.1',
        debugShowCheckedModeBanner: false,
        theme: temas[1],
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black26,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ui.themeMode.value,
        initialRoute: '/kanban', // Set the initial route to Kanban
        getPages: [
          GetPage(
            name: '/todo',
            page: () => const TodoListHomePage(),
            binding: BindingsBuilder(() {
              Get.put(TodoBackendController());
              Get.put(UIStateController());
            }),
          ),
          GetPage(name: '/money', page: () => const FinancialHomePage()),
          GetPage(name: '/template_app', page: () => const MyTemplateApp()),
          GetPage(
            name: '/kanban',
            page: () => const KanbanProApp(),
          ), // Kanban route
        ],
        locale: Get.deviceLocale, // Add this line
        fallbackLocale: const Locale('en', 'US'), // And this line
      ),
    );
  }
}
