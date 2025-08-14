import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';
// Placeholder para ícones, em um projeto real, use um pacote como lucide_flutter
import 'package:flutter/cupertino.dart';

// =============================================================================
// MODELOS DE DADOS
// =============================================================================

// Usando classes simples para representar os modelos de dados
class ProjectItem {
  String id;
  String title;
  String status;
  String category;
  String? content;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> files;

  ProjectItem({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    this.content,
    required this.createdAt,
    required this.updatedAt,
    this.files = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'status': status,
    'category': category,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'files': files,
  };

  static ProjectItem fromJson(Map<String, dynamic> json) => ProjectItem(
    id: json['id'],
    title: json['title'],
    status: json['status'],
    category: json['category'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    files: List<String>.from(json['files'] ?? []),
  );
}

class FileAttachment {
  String id;
  String name;
  String type;
  String url;
  int size;
  String? projectId;
  DateTime uploadedAt;

  FileAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    this.projectId,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'url': url,
    'size': size,
    'projectId': projectId,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  static FileAttachment fromJson(Map<String, dynamic> json) => FileAttachment(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    url: json['url'],
    size: json['size'],
    projectId: json['projectId'],
    uploadedAt: DateTime.parse(json['uploadedAt']),
  );
}

class PomodoroSession {
  String id;
  String projectId;
  String projectTitle;
  String category;
  String type;
  int duration;
  DateTime completedAt;
  String date;

  PomodoroSession({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.category,
    required this.type,
    required this.duration,
    required this.completedAt,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'projectTitle': projectTitle,
    'category': category,
    'type': type,
    'duration': duration,
    'completedAt': completedAt.toIso8601String(),
    'date': date,
  };

  static PomodoroSession fromJson(Map<String, dynamic> json) => PomodoroSession(
    id: json['id'],
    projectId: json['projectId'],
    projectTitle: json['projectTitle'],
    category: json['category'],
    type: json['type'],
    duration: json['duration'],
    completedAt: DateTime.parse(json['completedAt']),
    date: json['date'],
  );
}

// =============================================================================
// REPOSITÓRIO DE DADOS (LÓGICA DE NEGÓCIO)
// =============================================================================

class DataRepository {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository.getInstance() => _instance;
  DataRepository._internal();

  List<ProjectItem> _projects = [];
  List<FileAttachment> _files = [];
  List<PomodoroSession> _pomodoroSessions = [];

  // Exemplo de dados iniciais
  void _loadInitialData() {
    _projects = [
      ProjectItem(
        id: '1',
        title: 'Desenvolver App Flutter',
        status: 'in progress',
        category: 'flutter',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        content: '- [x] Setup\n- [ ] UI',
      ),
      ProjectItem(
        id: '2',
        title: 'Relatório Semanal',
        status: 'todo',
        category: 'ons',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProjectItem(
        id: '3',
        title: 'Estudar Documentação do Firebase',
        status: 'concluido',
        category: 'backend',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    _files = [
      FileAttachment(
        id: 'f1',
        name: 'diagrama.png',
        type: 'image',
        url: 'https://placehold.co/600x400',
        size: 12345,
        projectId: '1',
        uploadedAt: DateTime.now(),
      ),
    ];
    _pomodoroSessions = [];
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final projectsJson = prefs.getString('projects');
      if (projectsJson != null) {
        final List<dynamic> decoded = jsonDecode(projectsJson);
        _projects = decoded.map((item) => ProjectItem.fromJson(item)).toList();
      } else {
        _loadInitialData();
      }
      // Carregar outros dados (files, pomodoro) da mesma forma
    } catch (e) {
      print("Erro ao carregar dados: $e");
      _loadInitialData();
    }
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = jsonEncode(_projects.map((p) => p.toJson()).toList());
    await prefs.setString('projects', projectsJson);
    // Salvar outros dados da mesma forma
    print("Dados salvos com sucesso!");
  }

  // Métodos CRUD para Projetos
  List<ProjectItem> getProjects() => _projects;
  List<ProjectItem> getProjectsByStatus(String status) =>
      _projects.where((p) => p.status == status).toList();
  void addProject(ProjectItem project) => _projects.add(project);
  void updateProject(
    String id, {
    String? title,
    String? status,
    String? content,
    String? category,
  }) {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index != -1) {
      if (title != null) _projects[index].title = title;
      if (status != null) _projects[index].status = status;
      if (content != null) _projects[index].content = content;
      if (category != null) _projects[index].category = category;
      _projects[index].updatedAt = DateTime.now();
    }
  }

  void deleteProject(String id) => _projects.removeWhere((p) => p.id == id);

  // Métodos para Arquivos
  List<FileAttachment> getFiles() => _files;
  List<FileAttachment> getFilesByProject(String projectId) =>
      _files.where((f) => f.projectId == projectId).toList();
  void addFile(FileAttachment file) => _files.add(file);
  void deleteFile(String id) => _files.removeWhere((f) => f.id == id);

  // Métodos para Pomodoro
  List<PomodoroSession> getPomodoroSessions() => _pomodoroSessions;
  void addPomodoroSession(PomodoroSession session) =>
      _pomodoroSessions.add(session);
  List<PomodoroSession> getPomodoroSessionsByDate(String date) {
    return _pomodoroSessions.where((s) => s.date == date).toList();
  }

  // Métodos de estatísticas
  Map<String, int> getStatusStats() {
    Map<String, int> stats = {};
    for (var project in _projects) {
      stats.update(project.status, (value) => value + 1, ifAbsent: () => 1);
    }
    return stats;
  }
}

// =============================================================================
// MAIN APP
// =============================================================================

class KanbanProApp extends StatefulWidget {
  const KanbanProApp({super.key});

  @override
  State<KanbanProApp> createState() => _KanbanProAppState();
}

class _KanbanProAppState extends State<KanbanProApp> {
  final DataRepository _repo = DataRepository.getInstance();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _repo.loadFromStorage();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : KanbanScreen(repository: _repo, refreshParent: _loadData);
  }
}

// =============================================================================
// TELA KANBAN
// =============================================================================

const Map<String, Map<String, dynamic>> STATUS_COLUMNS = {
  'backlog': {'title': 'Backlog', 'emoji': '📦'},
  'todo': {'title': 'A Fazer', 'emoji': '📝'},
  'in progress': {'title': 'Em Progresso', 'emoji': '⏳'},
  'review': {'title': 'Revisão', 'emoji': '👀'},
  'concluido': {'title': 'Concluído', 'emoji': '✅'},
};

class KanbanScreen extends StatefulWidget {
  final DataRepository repository;
  final VoidCallback refreshParent;

  const KanbanScreen({
    super.key,
    required this.repository,
    required this.refreshParent,
  });

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  late List<ProjectItem> projects;

  @override
  void initState() {
    super.initState();
    projects = widget.repository.getProjects();
  }

  void _updateProjectStatus(String projectId, String newStatus) {
    setState(() {
      widget.repository.updateProject(projectId, status: newStatus);
      projects = widget.repository.getProjects();
      widget.repository.saveToStorage();
    });
  }

  void _showItemEditor(ProjectItem item) async {
    await showDialog(
      context: context,
      builder: (context) =>
          ItemEditorDialog(item: item, repository: widget.repository),
    );
    // Recarregar os dados após fechar o editor
    setState(() {
      projects = widget.repository.getProjects();
    });
  }

  void _createNewItem(String status) {
    final newItem = ProjectItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Novo Item',
      status: status,
      category: 'ons',
      content: '# Novo Item\n- [ ] Tarefa 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    widget.repository.addProject(newItem);
    _showItemEditor(newItem);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kanban Board',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Organize seus projetos visualmente',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: STATUS_COLUMNS.length,
            itemBuilder: (context, index) {
              final status = STATUS_COLUMNS.keys.elementAt(index);
              final columnInfo = STATUS_COLUMNS[status]!;
              final items = projects.where((p) => p.status == status).toList();

              return DragTarget<ProjectItem>(
                onAcceptWithDetails: (details) {
                  _updateProjectStatus(details.data.id, status);
                },
                builder: (context, candidateData, rejectedData) {
                  return KanbanColumn(
                    title: columnInfo['title']!,
                    emoji: columnInfo['emoji']!,
                    items: items,
                    onCardTapped: _showItemEditor,
                    onAddItem: () => _createNewItem(status),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class KanbanColumn extends StatelessWidget {
  final String title;
  final String emoji;
  final List<ProjectItem> items;
  final Function(ProjectItem) onCardTapped;
  final VoidCallback onAddItem;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.emoji,
    required this.items,
    required this.onCardTapped,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[400],
                  child: Text(
                    items.length.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: onAddItem,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final card = KanbanCard(
                  item: item,
                  onTapped: () => onCardTapped(item),
                );

                return LongPressDraggable<ProjectItem>(
                  data: item,
                  feedback: Transform.rotate(
                    angle: 0.05,
                    child: SizedBox(width: 284, child: card),
                  ),
                  child: card,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class KanbanCard extends StatelessWidget {
  final ProjectItem item;
  final VoidCallback onTapped;

  const KanbanCard({super.key, required this.item, required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTapped,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              if (item.content != null && item.content!.isNotEmpty)
                ChecklistProgress(content: item.content!),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(item.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Icon(Icons.edit, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChecklistProgress extends StatelessWidget {
  final String content;

  const ChecklistProgress({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final checklistItems = RegExp(r'- \[x ]\]').allMatches(content).length;
    final completedItems = RegExp(r'- \[x\]').allMatches(content).length;

    if (checklistItems == 0) return const SizedBox.shrink();

    final progress = completedItems / checklistItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            Text(
              '$completedItems/$checklistItems',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }
}

// =============================================================================
// EDITOR DE ITENS (MODAL/DIALOG)
// =============================================================================
class ItemEditorDialog extends StatefulWidget {
  final ProjectItem item;
  final DataRepository repository;

  const ItemEditorDialog({
    super.key,
    required this.item,
    required this.repository,
  });

  @override
  State<ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<ItemEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  bool _showPreview = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _contentController = TextEditingController(text: widget.item.content);
    _selectedCategory = widget.item.category;
  }

  void _saveItem() {
    widget.repository.updateProject(
      widget.item.id,
      title: _titleController.text,
      content: _contentController.text,
      category: _selectedCategory,
    );
    widget.repository.saveToStorage();
    Navigator.of(context).pop();
  }

  void _deleteItem() {
    widget.repository.deleteProject(widget.item.id);
    widget.repository.saveToStorage();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Editar Item'),
          IconButton(
            icon: Icon(_showPreview ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showPreview = !_showPreview),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 16),
              // Simulação do seletor de categoria
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['ons', 'python', 'flutter', 'backend']
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Conteúdo (Markdown)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 15,
                      onChanged: (value) =>
                          setState(() {}), // para atualizar o preview
                    ),
                  ),
                  if (_showPreview) const SizedBox(width: 16),
                  if (_showPreview)
                    Expanded(
                      child: Container(
                        height: 350,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: Markdown(data: _contentController.text),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _deleteItem,
          child: const Text('Excluir', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _saveItem, child: const Text('Salvar')),
      ],
    );
  }
}
