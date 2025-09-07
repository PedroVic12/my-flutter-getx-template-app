import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mui_dashboard_app/modules/products/domain/entities/product.dart';
import 'package:mui_dashboard_app/modules/products/presentation/view_models/product_viewmodel.dart';
import 'package:mui_dashboard_app/modules/products/presentation/widgets/dialogs/edit_product_dialog.dart';
import 'package:mui_dashboard_app/modules/products/presentation/widgets/dialogs/update_product_quantity_dialog.dart';

class ProductItemWidget extends StatelessWidget {
  final Product product;

  const ProductItemWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<ProductViewModel>().deleteProduct(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product "${product.name}" removed')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(product.name),
          subtitle: Text('Quantity: ${product.quantity}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () =>
                    _showUpdateQuantityDialog(context, product, false),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () =>
                    _showUpdateQuantityDialog(context, product, true),
              ),
            ],
          ),
          onTap: () => _showEditProductDialog(context, product),
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => EditProductDialog(
        product: product,
        onEdit: (newName) {
          context.read<ProductViewModel>().updateProductName(
            product.id,
            newName,
          );
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _showUpdateQuantityDialog(
    BuildContext context,
    Product product,
    bool isInput,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => UpdateProductQuantityDialog(
        product: product,
        isInput: isInput,
        onUpdate: (quantityChange) {
          context.read<ProductViewModel>().updateProductQuantity(
            product.id,
            quantityChange,
          );
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}
