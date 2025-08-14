
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gohan_treinamentos_app/models/kanban_models.dart';

class KanbanRepository {
  final String kanbanFilePath;

  KanbanRepository({required this.kanbanFilePath});

  Future<String> _getAbsoluteKanbanPath() async {
    return kanbanFilePath;
  }

  Future<List<ProjectItem>> loadKanbanFromMarkdown() async {
    try {
      final String absolutePath = await _getAbsoluteKanbanPath();
      final File file = File(absolutePath);
      if (!await file.exists()) {
        print('Kanban file not found at: $absolutePath');
        return [];
      }

      final String content = await file.readAsString();
      return _parseMarkdownToKanban(content);
    } catch (e) {
      print('Error loading Kanban from Markdown: $e');
      return [];
    }
  }

  Future<void> saveKanbanToMarkdown(List<ProjectItem> projects) async {
    try {
      final String absolutePath = await _getAbsoluteKanbanPath();
      final File file = File(absolutePath);
      final String markdownContent = _generateMarkdownFromKanban(projects);
      await file.writeAsString(markdownContent);
    } catch (e) {
      print('Error saving Kanban to Markdown: $e');
    }
  }

  List<ProjectItem> _parseMarkdownToKanban(String markdownContent) {
    final List<ProjectItem> projects = [];
    final lines = markdownContent.split('\n');

    String? currentStatus;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('## ')) {
        currentStatus = line.substring(3).trim().toLowerCase();
      } else if (line.startsWith('- [ ') || line.startsWith('- [x]')) {
        if (currentStatus != null) {
          final isCompleted = line.startsWith('- [x]');
          final title = line.substring(line.indexOf(']') + 1).trim();
          
          // Basic parsing, you might need more sophisticated logic
          // to extract category, content, etc. from the markdown.
          // For now, we'll use placeholders or derive from status.
          projects.add(ProjectItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            title: title,
            status: currentStatus,
            category: 'general', // Placeholder
            content: line, // Store the full line for now
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      }
    }
    return projects;
  }

  String _generateMarkdownFromKanban(List<ProjectItem> projects) {
    final StringBuffer buffer = StringBuffer();
    final Map<String, List<ProjectItem>> projectsByStatus = {};

    // Group projects by status
    for (var project in projects) {
      projectsByStatus.putIfAbsent(project.status, () => []).add(project);
    }

    // Define a consistent order for statuses
    const orderedStatuses = [
      'backlog', 'todo', 'in progress', 'concluido', 'review',
      'uff', 'ons', 'agentes', 'parados', // Add custom statuses from your MD
    ];

    for (var status in orderedStatuses) {
      if (projectsByStatus.containsKey(status)) {
        // Capitalize first letter for display in Markdown header
        final displayStatus = status.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
        buffer.writeln('## $displayStatus');
        for (var project in projectsByStatus[status]!) {
          // Assuming content already contains the markdown checkbox format
          buffer.writeln(project.content ?? '- [ ] ${project.title}');
        }
        buffer.writeln(); // Add an empty line for separation
      }
    }
    return buffer.toString();
  }
}
