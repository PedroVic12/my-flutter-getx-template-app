import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_template_app/domain/controllers/backend_controller.dart';
import 'views/pages/todo_list_page.dart';

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
        title: 'My App Template V 3.1.1',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 55, 104, 197),
          ),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black26,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ui.themeMode.value,
        home: const TodoListHomePage(),
      ),
    );
  }
}
