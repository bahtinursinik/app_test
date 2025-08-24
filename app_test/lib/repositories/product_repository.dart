import 'dart:async';

import 'package:app_test/service/product_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/product.dart';

class ProductRepository {
  final ProductService service;
  final Box<Product> box;

  ProductRepository(this.service, {Box<Product>? box})
    : box = box ?? Hive.box<Product>('products');

  List<Product> getLocalProducts() => box.values.toList();

  dynamic _getKeyById(int id) {
    try {
      return box.keys.firstWhere((k) => box.get(k)?.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Product> addOrUpdateProduct(Product product) async {
    final key = product.hiveKey ?? _getKeyById(product.id ?? -1);

    if (key != null) {
      product.hiveKey = key;
      await box.put(key, product);
    } else {
      final newKey = await box.add(product);
      product.hiveKey = newKey;
    }

    try {
      final updated = await service.updateProduct(product);
      final keyAfter = updated.hiveKey ?? _getKeyById(updated.id ?? -1);
      if (keyAfter != null) {
        updated.hiveKey = keyAfter;
        await box.put(keyAfter, updated);
      } else {
        final newKey = await box.add(updated);
        updated.hiveKey = newKey;
      }
      return updated;
    } catch (_) {
      return product;
    }
  }

  Future<void> deleteProduct(Product product, {bool apiCall = true}) async {
    final key = product.hiveKey ?? _getKeyById(product.id ?? -1);
    if (key != null) await box.delete(key);

    if (apiCall && product.id != null) {
      unawaited(service.deleteProduct(product.id!));
    }
  }

  Future<void> syncProducts() async {
    try {
      final apiProducts = await service.fetchProducts();
      for (var p in apiProducts) {
        final key = _getKeyById(p.id ?? -1);
        if (key != null) {
          p.hiveKey = key;
          await box.put(key, p);
        } else {
          final newKey = await box.add(p);
          p.hiveKey = newKey;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync error: $e');
      }
    }
  }
}
