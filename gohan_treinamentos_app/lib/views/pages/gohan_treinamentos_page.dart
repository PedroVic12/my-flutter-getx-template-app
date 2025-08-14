import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gohan_treinamentos_app/controllers/theme_controller.dart';
import 'package:gohan_treinamentos_app/views/pages/profile_page.dart';
import 'package:gohan_treinamentos_app/views/pages/settings_page.dart';
import 'package:gohan_treinamentos_app/views/pages/workout_page.dart';
import 'package:gohan_treinamentos_app/views/pages/home_page.dart';

// Widgets (moved from original App.tsx, now in separate files or here if shared)
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

// Controller for GohanTreinamentosPage navigation
class GohanNavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }
}

class GohanTreinamentosPage extends StatelessWidget {
  const GohanTreinamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GohanNavigationController navController = Get.put(GohanNavigationController());

    return Obx(
      () => IndexedStack(
        index: navController.selectedIndex.value,
        children: [
          const HomePage(),
          const ProfilePage(),
          WorkoutPage(),
          SettingsPage(),
        ],
      ),
    );
  }
}