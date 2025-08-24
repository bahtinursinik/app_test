import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  final String baseUrl;
  final http.Client client;

  ProductService({
    this.baseUrl = 'https://fakestoreapi.com',
    http.Client? client,
  }) : client = client ?? http.Client();

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<List<Product>> fetchProducts() async {
    final res = await client.get(
      Uri.parse('$baseUrl/products'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  Future<Product> addProduct(Product product) async {
    final res = await client.post(
      Uri.parse('$baseUrl/products'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Product.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to add product');
    }
  }

  Future<Product> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception('Product id is required for update');
    }
    final res = await client.put(
      Uri.parse('$baseUrl/products/${product.id}'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );
    if (res.statusCode == 200) {
      return Product.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final res = await client.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
}
