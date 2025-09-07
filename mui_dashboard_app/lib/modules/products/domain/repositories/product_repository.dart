import 'package:mui_dashboard_app/modules/products/domain/entities/product.dart';

abstract class IProductRepository {
  List<Product> getAllProducts();
  void addProduct(Product product);
  void updateProduct(Product product);
  void deleteProduct(String id);
}
