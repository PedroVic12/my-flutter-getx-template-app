// MENU DRAWER
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/controllers/backend_controller.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final ui = Get.find<UIStateController>();
    return Drawer(
      child: Obx(
        () => ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Todos'),
              selected: ui.selectedPage.value == 0,
              onTap: () {
                ui.selectPage(0);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre'),
              selected: ui.selectedPage.value == 1,
              onTap: () {
                ui.selectPage(1);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
