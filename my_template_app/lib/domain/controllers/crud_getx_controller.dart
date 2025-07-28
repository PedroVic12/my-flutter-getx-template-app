import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// --- MAIN - Ponto de entrada da aplicação ---
void main() async {
  // Garante que os widgets do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o GetStorage para persistência de dados local
  await GetStorage.init();
  runApp(const MyApp());
}

// --- CONTROLLER (GetX) - Lógica de estado e de negócios ---
class DataController extends GetxController {
  // Observáveis para reatividade da UI
  var dataList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();

  // URL da API. Para emulador Android, use 10.0.2.2 para acessar o localhost do seu computador.
  // Para iOS ou Web, use 'localhost' ou '127.0.0.1'.
  final String _apiUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8000/dados'
      : 'http://localhost:8000/dados';

  @override
  void onInit() {
    super.onInit();
    // Carrega os últimos dados salvos quando o app inicia
    loadDataFromStorage();
  }

  void loadDataFromStorage() {
    // Tenta ler a chave 'last_data' do storage
    final savedData = _storage.read<List>('last_data');
    if (savedData != null) {
      // Converte a lista dinâmica para o tipo esperado e atualiza o estado
      dataList.value = List<Map<String, dynamic>>.from(savedData);
    }
  }

  Future<void> pickAndProcessFile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Abre o seletor de arquivos
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.first;

        // Cria o FormData para enviar o arquivo via POST
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path!, filename: file.name),
        });

        // Faz a requisição para a API
        final response = await _dio.post(_apiUrl, data: formData);

        if (response.statusCode == 200) {
          final List<dynamic> responseData = response.data;
          // Atualiza a lista de dados com a resposta da API
          dataList.value = List<Map<String, dynamic>>.from(responseData);
          // Salva os novos dados no storage local
          await _storage.write('last_data', responseData);
        } else {
          errorMessage.value = 'Erro na API: ${response.statusMessage}';
        }
      } else {
        // Usuário cancelou a seleção do arquivo
      }
    } on DioException catch (e) {
      // Trata erros de conexão ou da API
      errorMessage.value = 'Erro de conexão: ${e.message}';
    } catch (e) {
      // Trata outros erros inesperados
      errorMessage.value = 'Ocorreu um erro inesperado: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

// --- APP WIDGET - Configuração do GetMaterialApp ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Data Pipeline',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

// --- VIEW - A tela principal da aplicação ---
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final DataController controller = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cliente de Dados'), centerTitle: true),
      body: Center(
        // Obx reage às mudanças nas variáveis observáveis do controller
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            );
          }
          if (controller.dataList.isEmpty) {
            return const Text(
              'Nenhum dado carregado.\nClique no botão para buscar um arquivo.',
              textAlign: TextAlign.center,
            );
          }
          // Se houver dados, exibe em uma ListView
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: controller.dataList.length,
            itemBuilder: (context, index) {
              final item = controller.dataList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(child: Text((index + 1).toString())),
                  title: Text(item.toString()),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.pickAndProcessFile();
        },
        icon: const Icon(Icons.upload_file),
        label: const Text("Processar Arquivo"),
      ),
    );
  }
}
