
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gohan_treinamentos_app/controllers/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);
  final RxBool notificationsEnabled = true.obs;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Card(
          child: Column(
            children: [
               Obx(() => SwitchListTile(
                    title: const Text("Enable Notifications"),
                    secondary: const Icon(Icons.notifications),
                    value: notificationsEnabled.value,
                    onChanged: (val) => notificationsEnabled.value = val,
                  )),
              const Divider(height: 1),
              Obx(() => SwitchListTile(
                    title: const Text("Dark Mode"),
                    secondary: const Icon(Icons.dark_mode),
                    value: Get.find<ThemeController>().themeMode.value == ThemeMode.dark,
                    onChanged: (val) => Get.find<ThemeController>().toggleTheme(),
                  )),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.language),
                title: Text("Language"),
                subtitle: Text("Português (Brasil)"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
