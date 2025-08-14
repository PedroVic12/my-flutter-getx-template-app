import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// MODEL
class TodoModel {
  int id;
  String title;
  bool done;
  String note;
  String status;
  int xp;
  TodoModel({
    required this.id,
    required this.title,
    this.done = false,
    this.note = "",
    this.status = 'TODO',
    this.xp = 0,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'],
    title: json['title'],
    done: json['done'] ?? false,
    note: json['note'] ?? "",
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'done': done,
    'note': note,
  };
}