import 'package:flutter/material.dart';
import 'package:mui_dashboard_app/modules/products/application/use_cases/product_usecases.dart';
import 'package:mui_dashboard_app/modules/products/domain/entities/product.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductUseCases _productUseCases;

  ProductViewModel(this._productUseCases);

  List<Product> get products => _productUseCases.getAllProducts();

  void addProduct(String name, int initialQuantity) {
    _productUseCases.addProduct(name, initialQuantity);
    notifyListeners();
  }

  void updateProductQuantity(String id, int change) {
    try {
      _productUseCases.updateProductQuantity(id, change);
      notifyListeners();
    } catch (e) {
      debugPrint('Product with ID $id not found: $e');
    }
  }

  void updateProductName(String id, String newName) {
    try {
      _productUseCases.updateProductName(id, newName);
      notifyListeners();
    } catch (e) {
      debugPrint('Product with ID $id not found: $e');
    }
  }

  void deleteProduct(String id) {
    _productUseCases.deleteProduct(id);
    notifyListeners();
  }

  // Dashboard metrics
  int get totalProducts => products.length;
  int get totalQuantity => products.fold(0, (sum, p) => sum + p.quantity);
}
