import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mui_dashboard_app/common/theme/view_models/theme_viewmodel.dart';
import 'package:mui_dashboard_app/navigation/views/main_navigation_screen.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, child) {
        return MaterialApp(
          title: 'MVVM Todo App',
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: themeViewModel.themeMode,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
