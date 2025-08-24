import 'dart:convert';

import 'package:app_test/models/product.dart';
import 'package:app_test/service/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../fixtures/product_fixture.dart';

void main() {
  group('ProductService', () {
    test('fetchProducts → 200 dönerse Product listesi döner', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(
          request.url.toString(),
          equals('https://fakestoreapi.com/products'),
        );
        expect(
          request.headers,
          containsPair('content-type', startsWith('application/json')),
        );

        return http.Response(
          jsonEncode([ProductFixture.sampleProductJson]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ProductService(client: mockClient);
      final products = await service.fetchProducts();

      expect(products, isA<List<Product>>());
      expect(
        products,
        contains(
          isA<Product>()
              .having((p) => p.id, 'id', 1)
              .having((p) => p.title, 'title', 'Test Product')
              .having((p) => p.price, 'price', 10.0)
              .having((p) => p.description, 'description', 'desc')
              .having((p) => p.category, 'category', 'cat'),
        ),
      );
    });

    test('fetchProducts → 500 dönerse exception fırlatır', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Server error', 500),
      );
      final service = ProductService(client: mockClient);

      expect(() => service.fetchProducts(), throwsException);
    });

    test('addProduct → 201 dönerse eklenen Product döner', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('https://fakestoreapi.com/products'),
        );
        expect(
          request.headers,
          containsPair('content-type', startsWith('application/json')),
        );

        final bodyMap = jsonDecode(request.body) as Map<String, dynamic>;
        expect(bodyMap['title'], 'Test Product');

        return http.Response(
          ProductFixture.sampleProductJsonString,
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ProductService(client: mockClient);

      final productToAdd = Product(
        id: null,
        title: 'Test Product',
        price: 10.0,
        description: 'desc',
        category: 'cat',
      );

      final addedProduct = await service.addProduct(productToAdd);

      expect(
        addedProduct,
        isA<Product>()
            .having((p) => p.id, 'id', 1)
            .having((p) => p.title, 'title', 'Test Product'),
      );
    });

    test('addProduct → 400/500 dönerse exception fırlatır', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Bad Request', 400),
      );
      final service = ProductService(client: mockClient);

      final product = Product(
        id: null,
        title: 'Test Product',
        price: 10.0,
        description: 'desc',
        category: 'cat',
      );

      expect(() => service.addProduct(product), throwsException);
    });

    test('updateProduct → id yoksa hemen exception fırlatır', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Should not be called', 500),
      );
      final service = ProductService(client: mockClient);

      final productWithoutId = Product(
        id: null,
        title: 'No Id',
        price: 0,
        description: 'desc',
        category: 'cat',
      );

      expect(() => service.updateProduct(productWithoutId), throwsException);
    });

    test('updateProduct → 200 dönerse güncellenen Product döner', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('PUT'));
        expect(
          request.url.toString(),
          equals('https://fakestoreapi.com/products/1'),
        );

        final updatedJson = Map<String, dynamic>.from(
          ProductFixture.sampleProductJson,
        )..['title'] = 'Updated Title';

        return http.Response(
          jsonEncode(updatedJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ProductService(client: mockClient);

      final updatedInput = Product(
        id: 1,
        title: 'Old Title',
        price: 10.0,
        description: 'desc',
        category: 'cat',
      );

      final updatedProduct = await service.updateProduct(updatedInput);

      expect(
        updatedProduct,
        isA<Product>()
            .having((p) => p.id, 'id', 1)
            .having((p) => p.title, 'title', 'Updated Title'),
      );
    });

    test('updateProduct → 404/500 dönerse exception fırlatır', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Not Found', 404),
      );
      final service = ProductService(client: mockClient);

      final product = Product(
        id: 1,
        title: 'Test Product',
        price: 10.0,
        description: 'desc',
        category: 'cat',
      );

      expect(() => service.updateProduct(product), throwsException);
    });

    test('deleteProduct → 200 dönerse tamamlanır', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(
          request.url.toString(),
          equals('https://fakestoreapi.com/products/1'),
        );
        return http.Response('', 200);
      });

      final service = ProductService(client: mockClient);
      await service.deleteProduct(1);

      expect(true, isTrue);
    });

    test('deleteProduct → 500 dönerse exception fırlatır', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Server error', 500),
      );
      final service = ProductService(client: mockClient);

      expect(() => service.deleteProduct(99), throwsException);
    });
  });
}
