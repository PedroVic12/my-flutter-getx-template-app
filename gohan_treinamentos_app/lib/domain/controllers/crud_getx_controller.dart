import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as DioPackage; // Alias Dio
import 'package:get_storage/get_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// --- CONTROLLER (GetX) - Lógica de estado e de negócios ---
class DataController extends GetxController {
  // Observáveis para reatividade da UI
  var dataList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final DioPackage.Dio _dio = DioPackage.Dio(); // Use aliased Dio
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
        DioPackage.FormData formData = DioPackage.FormData.fromMap({ // Use aliased FormData
          'file': await DioPackage.MultipartFile.fromFile(file.path!, filename: file.name), // Use aliased MultipartFile
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
    } on DioPackage.DioException catch (e) { // Use aliased DioException
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
