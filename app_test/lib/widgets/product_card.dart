import 'package:app_test/blocs/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/product.dart';
import 'product_form_dialog.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.teal.withOpacity(0.3),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        title: Text(
          product.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              "${product.price.toStringAsFixed(2)} \$",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (product.description != null)
              Text(
                product.description!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            const SizedBox(height: 6),
            if (product.category != null)
              Chip(
                label: Text(product.category!),
                backgroundColor: Colors.teal.shade50,
              ),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) =>
                            ProductFormDialog(isUpdate: true, product: product),
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Delete Product'),
                        content: const Text(
                          'Are you sure you want to delete this product?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                );
                if (confirm ?? false) {
                  context.read<ProductBloc>().add(DeleteProductEvent(product));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
