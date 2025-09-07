import 'package:mui_dashboard_app/common/entities/entity.dart';

class Product extends Entity {
  String name;
  int quantity;

  Product({required String id, required this.name, this.quantity = 0})
    : super(id: id);

  Product copyWith({String? name, int? quantity}) {
    return Product(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }
}