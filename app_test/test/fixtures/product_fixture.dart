import 'dart:convert';

import 'package:app_test/models/product.dart';

class ProductFixture {
  static Map<String, dynamic> get sampleProductJson => {
    "id": 1,
    "title": "Test Product",
    "price": 10.0,
    "description": "desc",
    "image": "img",
    "category": "cat",
  };

  static Product get sampleProduct => Product.fromJson(sampleProductJson);

  static String get sampleProductJsonString => jsonEncode(sampleProductJson);
}
