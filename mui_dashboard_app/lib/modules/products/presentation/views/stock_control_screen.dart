import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mui_dashboard_app/modules/products/presentation/view_models/product_viewmodel.dart';
import 'package:mui_dashboard_app/modules/products/presentation/widgets/product_item.dart';

class StockControlScreen extends StatelessWidget {
  const StockControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productViewModel, child) {
        if (productViewModel.products.isEmpty) {
          return const Center(child: Text('No products yet! Add a new one.'));
        }
        return ListView.builder(
          itemCount: productViewModel.products.length,
          itemBuilder: (context, index) {
            final product = productViewModel.products[index];
            return ProductItemWidget(product: product);
          },
        );
      },
    );
  }
}
