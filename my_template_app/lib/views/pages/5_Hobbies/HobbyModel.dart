import 'package:hive/hive.dart';

class Hobby {
  String title;
  String description;
  int count;

  Hobby({required this.title, required this.description, this.count = 0});

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      title: json['title'],
      description: json['description'],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'count': count};
  }
}

@HiveType(typeId: 0)
class MeuHobby {
  @HiveField(0)
  String? title;

  @HiveField(1)
  List<String>? description;

  @HiveField(2)
  late int contador;

  MeuHobby({required this.title, required this.description, this.contador = 0});

  MeuHobby.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'].cast<String>();
  }
  void increment() {
    contador++;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}
