
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';

// Widgets
void showToast(String message, {bool isError = false, Widget? action}) {
  Get.snackbar(
    isError ? 'Erro' : 'Sucesso',
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: isError ? Colors.red[600] : Colors.green[600],
    colorText: Colors.white,
    borderRadius: 8,
    margin: const EdgeInsets.all(10),
    mainButton: action != null 
        ? TextButton(
            onPressed: () {
              if (Get.isSnackbarOpen) Get.back();
            },
            child: action,
          )
        : null,
  );
}

void showCustomBottomSheet({required String title, required Widget content}) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: Get.textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(child: SingleChildScrollView(child: content)),
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               OutlinedButton(onPressed: ()=> Get.back(), child: const Text("Cancelar")),
               const SizedBox(width: 8),
               ElevatedButton(onPressed: ()=> Get.back(), child: const Text("Confirmar")),
             ],
           )
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Home Page", style: Get.textTheme.displaySmall),
          const SizedBox(height: 16),
          const Text("Welcome to the mobile app template 2025."),
          const SizedBox(height: 8),
          const Text("Use the buttons below to interact with the app."),
          const SizedBox(height: 16),
          const Text("Estou usando esse template para migrar um projeto em Flutter para React com Ionic para React com Vite e com todos os componentes com código limpo usando Material UI, Tailwind e Ionic."),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showCustomBottomSheet(
                title: "Example Bottom Sheet",
                content: Column(
                  children: const [
                    Text("This is the bottom sheet content."),
                    Text("It scrolls if needed. Lorem ipsum..."),
                  ],
                ),
              );
            },
            child: const Text("Open Bottom Sheet"),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => showToast("Operation successful!", isError: false),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                child: const Text("Show Success Toast"),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => showToast("Something went wrong!", isError: true),
                 style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Show Error Toast"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text("From Pedro Victor Veras Software developer.", style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
