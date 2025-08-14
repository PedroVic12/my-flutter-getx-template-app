import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gohan_treinamentos_app/views/pages/gohan_treinamentos_page.dart';
import 'package:gohan_treinamentos_app/views/pages/kanban_page.dart';
import 'package:gohan_treinamentos_app/views/pages/productivity_crud_page.dart';
import 'package:gohan_treinamentos_app/controllers/theme_controller.dart';
import 'package:gohan_treinamentos_app/views/main_layout.dart';
import 'package:gohan_treinamentos_app/views/pages/financial_app_controlefinanceiro.dart'; // Added import

import 'package:gohan_treinamentos_app/controllers/kanban_controller.dart';
import 'package:gohan_treinamentos_app/domain/controllers/crud_getx_controller.dart';

void main() {
  Get.put(ThemeController());
  Get.put(DataController());
  Get.put(KanbanController(kanbanFilePath: '/home/pedrov12/Documentos/GitHub/Jedi-CyberPunk/PVRV/KANBAN2025.md'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return Obx(() {
      return GetMaterialApp(
        title: 'Gohan Treinamentos App',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeController.themeMode.value,
        initialRoute: '/gohan',
        getPages: [
          GetPage(
              name: '/gohan',
              page: () => MainLayout(
                  title: 'Gohan Treinamentos',
                  child: GohanTreinamentosPage())),
          GetPage(
              name: '/kanban',
              page: () =>
                  MainLayout(title: 'Kanban Pro', child: KanbanProApp())), // Changed KanbanPage to KanbanProApp
          GetPage(
              name: '/productivity',
              page: () => MainLayout(
                  title: 'Produtividade',
                  child: ProductivityCRUDPage())),
          GetPage( // Added FinancialHomePage route
              name: '/money',
              page: () => MainLayout(
                  title: 'Controle Financeiro',
                  child: FinancialHomePage())),
        ],
      );
    });
  }
}