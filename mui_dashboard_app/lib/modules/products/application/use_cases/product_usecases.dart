import 'package:flutter/foundation.dart';
import 'package:mui_dashboard_app/modules/products/domain/entities/product.dart';
import 'package:mui_dashboard_app/modules/products/domain/repositories/product_repository.dart';

class ProductUseCases {
  final IProductRepository _repository;

  ProductUseCases(this._repository);

  List<Product> getAllProducts() => _repository.getAllProducts();

  void addProduct(String name, int initialQuantity) {
    if (name.trim().isEmpty || initialQuantity < 0) return;
    final product = Product(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      quantity: initialQuantity,
    );
    _repository.addProduct(product);
  }

  void updateProductQuantity(String id, int change) {
    final products = _repository.getAllProducts();
    final product = products.firstWhere((p) => p.id == id);
    if (product.quantity + change >= 0) {
      final updatedProduct = product.copyWith(
        quantity: product.quantity + change,
      );
      _repository.updateProduct(updatedProduct);
    }
  }

  void updateProductName(String id, String newName) {
    if (newName.trim().isEmpty) return;
    final products = _repository.getAllProducts();
    final product = products.firstWhere((p) => p.id == id);
    final updatedProduct = product.copyWith(name: newName.trim());
    _repository.updateProduct(updatedProduct);
  }

  void deleteProduct(String id) {
    _repository.deleteProduct(id);
  }
}
