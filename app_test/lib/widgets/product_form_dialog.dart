import 'package:app_test/blocs/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product.dart';
import 'product_text_field.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final bool isUpdate;

  const ProductFormDialog({super.key, this.product, required this.isUpdate});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  String? selectedCategory;
  final customCategoryController = TextEditingController();

  final categories = ["Elektronik", "Kitap", "Giyim", "Gıda", "Other"];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.product?.title ?? '');
    priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );

    selectedCategory = widget.product?.category;
    if (selectedCategory != null && !categories.contains(selectedCategory)) {
      selectedCategory = "Other";
      customCategoryController.text = widget.product!.category!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isUpdate ? "Update Product" : "Add Product",
                  key: const Key('product_form_title'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ProductTextField(controller: titleController, label: "Title"),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: priceController,
                  label: "Price",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: descriptionController,
                  label: "Description",
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items:
                      categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => selectedCategory = val),
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                  ),
                  validator:
                      (val) => val == null ? "Please select a category" : null,
                ),
                if (selectedCategory == "Other")
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ProductTextField(
                      controller: customCategoryController,
                      label: "Custom Category",
                    ),
                  ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.isUpdate ? "Update" : "Add",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final category =
                              selectedCategory == "Other"
                                  ? customCategoryController.text
                                  : selectedCategory;

                          final newProduct = Product(
                            id:
                                widget.isUpdate
                                    ? widget.product!.id
                                    : DateTime.now().millisecondsSinceEpoch,
                            title: titleController.text,
                            price: double.parse(priceController.text),
                            description: descriptionController.text,
                            category: category!,
                            hiveKey: widget.product?.hiveKey,
                          );

                          if (widget.isUpdate) {
                            context.read<ProductBloc>().add(
                              UpdateProductEvent(newProduct),
                            );
                          } else {
                            context.read<ProductBloc>().add(
                              AddProductEvent(newProduct),
                            );
                          }

                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
