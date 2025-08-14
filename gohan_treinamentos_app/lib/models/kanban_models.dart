
import 'package:flutter/material.dart';

class ProjectItem {
  String id;
  String title;
  String status;
  String category;
  String? content;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> files; // Assuming file IDs or paths

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

  factory ProjectItem.fromJson(Map<String, dynamic> json) => ProjectItem(
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
  String type; // e.g., 'pdf', 'image', 'excel'
  String url; // Base64 encoded string or local path
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

  factory FileAttachment.fromJson(Map<String, dynamic> json) => FileAttachment(
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
  String type; // e.g., 'work', 'short-break'
  int duration; // in minutes
  DateTime completedAt;
  String date; // YYYY-MM-DD format

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

  factory PomodoroSession.fromJson(Map<String, dynamic> json) =>
      PomodoroSession(
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
