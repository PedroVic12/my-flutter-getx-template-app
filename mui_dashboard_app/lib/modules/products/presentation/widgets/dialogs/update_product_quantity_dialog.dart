import 'package:flutter/material.dart';
import 'package:mui_dashboard_app/modules/products/domain/entities/product.dart';

class UpdateProductQuantityDialog extends StatefulWidget {
  final Product product;
  final bool isInput;
  final ValueChanged<int> onUpdate;

  const UpdateProductQuantityDialog({
    super.key,
    required this.product,
    required this.isInput,
    required this.onUpdate,
  });

  @override
  State<UpdateProductQuantityDialog> createState() =>
      _UpdateProductQuantityDialogState();
}

class _UpdateProductQuantityDialogState
    extends State<UpdateProductQuantityDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isInput ? 'Add Quantity' : 'Subtract Quantity'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter quantity to ${widget.isInput ? 'add' : 'subtract'}',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final change = int.tryParse(_controller.text) ?? 0;
            if (change > 0) {
              widget.onUpdate(widget.isInput ? change : -change);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a positive quantity.'),
                ),
              );
            }
          },
          child: Text(widget.isInput ? 'Add' : 'Subtract'),
        ),
      ],
    );
  }
}
