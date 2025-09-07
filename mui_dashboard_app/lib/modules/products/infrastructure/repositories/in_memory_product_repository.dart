import 'package:mui_dashboard_app/modules/products/domain/entities/product.dart';
import 'package:mui_dashboard_app/modules/products/domain/repositories/product_repository.dart';

class InMemoryProductRepository implements IProductRepository {
  final List<Product> _products = [];

  @override
  List<Product> getAllProducts() => List.unmodifiable(_products);

  @override
  void addProduct(Product product) {
    _products.add(product);
  }

  @override
  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  @override
  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
  }
}
