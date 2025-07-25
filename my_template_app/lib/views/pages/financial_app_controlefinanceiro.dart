// flutter pub add intl shared_preferences file_picker excel path_provider

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

// ===== MODELS =====
class Transaction {
  final String id;
  final String description;
  final double value;
  final String type;
  final String category;
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.value,
    required this.type,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      value: (json['value'] as num).toDouble(),
      type: json['type'],
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  // Para exportar para Excel
  List<dynamic> toExcelRow() {
    return [
      description,
      value,
      type,
      category,
      DateFormat('dd/MM/yyyy').format(date),
    ];
  }

  // Para criar Transaction a partir de linha do Excel
  static Transaction fromExcelRow(List<dynamic> row, String id) {
    return Transaction(
      id: id,
      description: row[0]?.toString() ?? '',
      value: double.tryParse(row[1]?.toString() ?? '0') ?? 0.0,
      type: row[2]?.toString() ?? 'saida',
      category: row[3]?.toString() ?? 'Outros',
      date: _parseDate(row[4]?.toString() ?? ''),
    );
  }

  static DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}

// ===== REPOSITORY =====
class TransactionRepository {
  static const String _storageKey = 'financial_transactions';

  Future<List<Transaction>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsString = prefs.getString(_storageKey);

      if (transactionsString != null) {
        final List<dynamic> decoded = json.decode(transactionsString);
        return decoded.map((item) => Transaction.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar transações: $e');
      return [];
    }
  }

  Future<bool> saveTransactions(List<Transaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        transactions.map((t) => t.toJson()).toList(),
      );
      return await prefs.setString(_storageKey, encoded);
    } catch (e) {
      print('Erro ao salvar transações: $e');
      return false;
    }
  }

  Future<bool> exportToExcel(List<Transaction> transactions) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Transações'];

      // Cabeçalhos
      sheet.appendRow([
        TextCellValue('Descrição'),
        TextCellValue('Valor'),
        TextCellValue('Tipo'),
        TextCellValue('Categoria'),
        TextCellValue('Data'),
      ]);

      // Dados
      for (final transaction in transactions) {
        final row = transaction.toExcelRow();
        sheet.appendRow([
          TextCellValue(row[0].toString()),
          DoubleCellValue(row[1] as double),
          TextCellValue(row[2].toString()),
          TextCellValue(row[3].toString()),
          TextCellValue(row[4].toString()),
        ]);
      }

      // Salvar arquivo
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/transacoes_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao exportar: $e');
      return false;
    }
  }

  Future<List<Transaction>> importFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);

        final List<Transaction> transactions = [];

        for (final table in excel.tables.keys) {
          final sheet = excel.tables[table]!;

          // Pular cabeçalho (primeira linha)
          for (int i = 1; i < sheet.maxRows; i++) {
            final row = sheet.row(i);
            if (row.isNotEmpty && row[0]?.value != null) {
              final transaction = Transaction.fromExcelRow(
                row.map((cell) => cell?.value).toList(),
                DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
              );
              transactions.add(transaction);
            }
          }
        }

        return transactions;
      }
      return [];
    } catch (e) {
      print('Erro ao importar: $e');
      return [];
    }
  }
}

// ===== CONTROLLER =====
class TransactionController extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  double get income => _transactions
      .where((t) => t.type == 'entrada')
      .fold(0.0, (sum, t) => sum + t.value);

  double get expenses => _transactions
      .where((t) => t.type == 'saida')
      .fold(0.0, (sum, t) => sum + t.value);

  double get balance => income - expenses;

  List<Transaction> get sortedTransactions {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  Future<void> loadTransactions() async {
    _setLoading(true);
    _transactions = await _repository.getTransactions();
    _setLoading(false);
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    final success = await _repository.saveTransactions(_transactions);
    if (success) {
      notifyListeners();
    } else {
      _transactions.removeLast(); // Reverter em caso de erro
    }
    return success;
  }

  Future<bool> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    final removedTransaction = _transactions.removeAt(index);
    final success = await _repository.saveTransactions(_transactions);

    if (success) {
      notifyListeners();
    } else {
      _transactions.insert(
        index,
        removedTransaction,
      ); // Reverter em caso de erro
    }
    return success;
  }

  Future<bool> exportTransactions() async {
    if (_transactions.isEmpty) return false;
    return await _repository.exportToExcel(_transactions);
  }

  Future<bool> importTransactions() async {
    try {
      final importedTransactions = await _repository.importFromExcel();
      if (importedTransactions.isNotEmpty) {
        _transactions.addAll(importedTransactions);
        final success = await _repository.saveTransactions(_transactions);
        if (success) {
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      print('Erro ao importar transações: $e');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// ===== VIEW =====

class FinancialHomePage extends StatefulWidget {
  const FinancialHomePage({super.key});

  @override
  State<FinancialHomePage> createState() => _FinancialHomePageState();
}

class _FinancialHomePageState extends State<FinancialHomePage> {
  late final TransactionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransactionController();
    _controller.addListener(() => setState(() {}));
    _controller.loadTransactions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionForm(controller: _controller),
    );
  }

  void _showImportExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ImportExportDialog(controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Money 2025',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0f172a),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: _showImportExportDialog,
            tooltip: 'Importar/Exportar',
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Dashboard(controller: _controller),
                  const SizedBox(height: 24),
                  Text(
                    'Histórico',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TransactionHistory(controller: _controller),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final TransactionController controller;

  const Dashboard({super.key, required this.controller});

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryCard(
                  title: 'Receita',
                  value: _formatCurrency(controller.income),
                  color: Colors.green,
                ),
                _SummaryCard(
                  title: 'Despesa',
                  value: _formatCurrency(controller.expenses),
                  color: Colors.red,
                ),
                _SummaryCard(
                  title: 'Saldo',
                  value: _formatCurrency(controller.balance),
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class TransactionHistory extends StatelessWidget {
  final TransactionController controller;

  const TransactionHistory({super.key, required this.controller});

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  Future<void> _deleteTransaction(BuildContext context, String id) async {
    final success = await controller.deleteTransaction(id);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir transação')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = controller.sortedTransactions;

    return transactions.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Nenhuma transação ainda.'),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final t = transactions[index];
              final isIncome = t.type == 'entrada';
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIncome
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    t.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${t.category} - ${DateFormat('dd/MM/yyyy').format(t.date)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'} ${_formatCurrency(t.value)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => _deleteTransaction(context, t.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class TransactionForm extends StatefulWidget {
  final TransactionController controller;

  const TransactionForm({super.key, required this.controller});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  String _type = 'saida';
  String? _category;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _expenseCategories = [
    "Necessidades",
    "Lazer",
    "Investimentos",
    "Cartão Nubank",
    "Outros",
  ];
  final List<String> _incomeCategories = [
    "Salário",
    "Freelance",
    "Investimentos",
    "Outros",
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _descriptionController.text.trim(),
      value: double.parse(_valueController.text.replaceAll(',', '.')),
      type: _type,
      category: _category!,
      date: _date,
    );

    final success = await widget.controller.addTransaction(newTransaction);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao adicionar transação')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _type == 'saida'
        ? _expenseCategories
        : _incomeCategories;
    if (_category == null || !currentCategories.contains(_category)) {
      _category = currentCategories[0];
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: (val) =>
                  val?.trim().isEmpty == true ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (val) {
                if (val?.isEmpty == true) return 'Campo obrigatório';
                final value = double.tryParse(val!.replaceAll(',', '.'));
                if (value == null || value <= 0) return 'Valor inválido';
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'saida', child: Text('Saída')),
                DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
              ],
              onChanged: (value) => setState(() => _type = value!),
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            DropdownButtonFormField<String>(
              value: _category,
              items: currentCategories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Adicionar Transação'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ImportExportDialog extends StatefulWidget {
  final TransactionController controller;

  const ImportExportDialog({super.key, required this.controller});

  @override
  State<ImportExportDialog> createState() => _ImportExportDialogState();
}

class _ImportExportDialogState extends State<ImportExportDialog> {
  bool _isProcessing = false;

  Future<void> _exportTransactions() async {
    setState(() => _isProcessing = true);

    final success = await widget.controller.exportTransactions();

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Transações exportadas com sucesso!'
                : 'Erro ao exportar transações',
          ),
        ),
      );
    }
  }

  Future<void> _importTransactions() async {
    setState(() => _isProcessing = true);

    final success = await widget.controller.importTransactions();

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Transações importadas com sucesso!'
                : 'Erro ao importar transações',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar/Exportar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Escolha uma opção:'),
          const SizedBox(height: 20),
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _exportTransactions,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Exportar para Excel'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _importTransactions,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Importar do Excel'),
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
