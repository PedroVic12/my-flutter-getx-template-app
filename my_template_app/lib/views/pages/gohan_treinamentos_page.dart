import 'package:app_produtividade/pages/5%20Hobbies/widgets/desempenho_widget_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';

import 'package:intl/intl.dart';
import 'package:my_template_app/views/pages/5_Hobbies/HobbyModel.dart';
import 'package:my_template_app/views/pages/5_Hobbies/hobbies_controller.dart';
import 'package:my_template_app/views/widgets/CustomText.dart';

// TODO -> You only Need 5 Hobbies
//
//// TODO -> Faculdade
///
// TODO -> Estágio
///
/// TODO -> Freelancer App + Chatbot

/// TODO -> Organização + Planejamento + Metas

class BlogPage2 extends StatefulWidget {
  BlogPage2({super.key});

  @override
  State<BlogPage2> createState() => _BlogPage2State();
}

class _BlogPage2State extends State<BlogPage2> {
  final LocalStorage storage = LocalStorage('hobbies_storage');
  final HobbyController _controller = Get.put(HobbyController());

  final List<Hobby> hobbies = [
    Hobby(
      title: "One to make your money",
      description: "Estágio em Engenharia Camorim, Citta Delivery App",
    ),
    Hobby(
      title: "One to keep you in shape",
      description:
          "Calistenia App + Movimentos Calistenicos + Treino Academia + Força",
    ),
    Hobby(
      title: "One to build Knowledge",
      description: " 2 Disciplinas da UFF por Dia , 2 Aulas + 5 Exercicios",
    ),
    Hobby(
      title: "One to grow your mindset",
      description:
          "Fazer 1 Projeto que Resolva problemas, colocar em pratica algo que voce aprendeu",
    ),
    Hobby(
      title: "One to stay creactive",
      description:
          "Ler 1 Capitulo de um Livro, Documentario, Estudar sobre algo Novo/Revolucionario",
    ),
  ];
  int get totalHobbiesCount =>
      hobbies.fold(0, (previousValue, hobby) => previousValue + hobby.count);

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  getDataAtual() {
    DateTime dataAtual = DateTime.now();
    String dataFormatada = DateFormat('EEEE - dd/MM/yyyy').format(dataAtual);
    return dataFormatada;
  }

  _loadCounts() async {
    await storage.ready;

    for (int i = 0; i < hobbies.length; i++) {
      hobbies[i].count = storage.getItem('hobby_count_$i') ?? 0;
    }
    setState(() {});
  }

  _saveCounts() async {
    for (int i = 0; i < hobbies.length; i++) {
      storage.setItem('hobby_count_$i', hobbies[i].count);
    }
  }

  _resetCounts() {
    for (var hobby in hobbies) {
      hobby.count = 0;
    }
    _saveCounts();
    setState(() {});

    Get.snackbar(
      'Rotinas Resetadas!',
      'Tenha um otimo inicio de semana :) ',
      showProgressIndicator: true,
      backgroundColor: Colors.redAccent.shade200,
    );
  }

  void showCustomSnackbar(String title, String message) {
    Get.snackbar(
      title, // Título da Snackbar
      message, // Mensagem da Snackbar
      snackPosition: SnackPosition.BOTTOM, // Posição da Snackbar
      duration: Duration(seconds: 3), // Duração da exibição
      backgroundColor: Colors.blue, // Cor de fundo
      colorText: Colors.white, // Cor do texto
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Gohan Treinamentos',
          size: 24,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetCounts,
              tooltip: "Reset counts",
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // TODO -> Transformar num Widget
          Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  getDataAtual(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const CustomText(
            text: 'You Only Need 5 hobbies',
            size: 18,
            weight: FontWeight.bold,
          ),

          // DesempenhoCardWidget(
          //     data: '04/06/24',
          //     total: 21,
          //     hiperfoco: 'Knowlodge',
          //     rendimento: 'Pouca atividade e força de vontade',
          //     onLongPressCard: () {
          //       Get.to(HistoricoDesempenhoCardWidget());
          //     }),
          Expanded(
            child: ListView.builder(
              itemCount: hobbies.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.amber,
                  margin: const EdgeInsets.all(8.0),
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: ListTile(
                    title: Text(
                      hobbies[index].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                    subtitle: Text(
                      hobbies[index].description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          child: Text(hobbies[index].count.toString()),
                        ),
                        SizedBox(width: 16),
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade500,
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                hobbies[index].count++;
                                _saveCounts();
                              });

                              showCustomSnackbar(
                                '${hobbies[index].title}',
                                'Tarefa adicionada! Continue tentando!',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Divider(),
                Text(
                  "Desempenho da semana: ${totalHobbiesCount}/35",
                  style: const TextStyle(fontSize: 20),
                ),
                LinearProgressIndicator(
                  value: totalHobbiesCount / 35,
                  color: Colors.black,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  backgroundColor: Colors.grey[200],
                ),
                Divider(),
              ],
            ),
          ),

          //BotaoNavegacao(        pagina: ContadorPage(), titlePagina: 'Pagina de Incrementador'),

          //CardProdutividade()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
