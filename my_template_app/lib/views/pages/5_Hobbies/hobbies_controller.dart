import 'package:get/get.dart';

import 'HobbyModel.dart';

class HobbyController extends GetxController {
  final hobbies = <Hobby>[
    Hobby(
      title: "One to make your money",
      description:
          "Estágio em Engenharia, Citta Delivery App, Iniciação Cientifica",
    ),
    // Adicione outros hobbies aqui
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCounts();
  }

  void _loadCounts() {
    for (int i = 0; i < hobbies.length; i++) {
      hobbies[i].count = _loadCount(i) ?? 0;
    }
  }

  int? _loadCount(int index) {
    // Implemente o carregamento dos contadores aqui (localStorage, SharedPreferences, etc.).
    return null;
  }

  void incrementCount(int index) {
    hobbies[index].count++;
    _saveCount(index);
  }

  void _saveCount(int index) {
    // Implemente a lógica de salvamento dos contadores aqui (localStorage, SharedPreferences, etc.).
  }

  void resetCounts() {
    for (var hobby in hobbies) {
      hobby.count = 0;
      _saveCount(hobbies.indexOf(hobby));
    }
  }
}
