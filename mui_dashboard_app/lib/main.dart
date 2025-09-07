import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mui_dashboard_app/app/app.dart';
import 'package:mui_dashboard_app/common/theme/view_models/theme_viewmodel.dart';
import 'package:mui_dashboard_app/modules/products/application/use_cases/product_usecases.dart';
import 'package:mui_dashboard_app/modules/products/infrastructure/repositories/in_memory_product_repository.dart';
import 'package:mui_dashboard_app/modules/products/presentation/view_models/product_viewmodel.dart';
import 'package:mui_dashboard_app/modules/todos/application/use_cases/todo_usecases.dart';
import 'package:mui_dashboard_app/modules/todos/infrastructure/repositories/in_memory_todo_repository.dart';
import 'package:mui_dashboard_app/modules/todos/presentation/view_models/todo_viewmodel.dart';

void main() {
  // Dependency Injection Container
  final todoRepository = InMemoryTodoRepository();
  final productRepository = InMemoryProductRepository();
  final todoUseCases = TodoUseCases(todoRepository);
  final productUseCases = ProductUseCases(productRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => TodoViewModel(todoUseCases)),
        ChangeNotifierProvider(
          create: (_) => ProductViewModel(productUseCases),
        ),
      ],
      child: const TodoApp(),
    ),
  );
}