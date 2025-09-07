import 'package:flutter/material.dart';
import 'package:mui_dashboard_app/modules/products/domain/entities/product.dart';

class EditProductDialog extends StatefulWidget {
  final Product product;
  final ValueChanged<String> onEdit;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.onEdit,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.product.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Product Name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter new product name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: widget.onEdit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => widget.onEdit(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
