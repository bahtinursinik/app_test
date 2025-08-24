import 'package:app_test/models/product.dart';
import 'package:app_test/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mock/mock_classes.dart';

class ProductFake extends Fake implements Product {}

void main() {
  late MockProductService mockService;
  late MockBox<Product> mockBox;
  late ProductRepository repository;

  setUpAll(() {
    registerFallbackValue(ProductFake());
  });

  setUp(() {
    mockService = MockProductService();
    mockBox = MockBox<Product>();
    repository = ProductRepository(mockService, box: mockBox);
  });

  final testProduct = Product(
    id: 1,
    title: 'Test Product',
    price: 10.0,
    description: 'desc',
    category: 'cat',
  );

  group('ProductRepository', () {
    test('getLocalProducts returns box values', () {
      when(() => mockBox.values).thenReturn([testProduct]);

      final products = repository.getLocalProducts();

      expect(products, isA<List<Product>>());
      expect(products.length, 1);
      expect(products.first.title, 'Test Product');
    });

    test('addOrUpdateProduct adds product if new', () async {
      when(() => mockBox.add(testProduct)).thenAnswer((_) async => 0);
      when(
        () => mockBox.put(any<dynamic>(), any<Product>()),
      ).thenAnswer((_) async {});
      when(
        () => mockService.updateProduct(testProduct),
      ).thenAnswer((_) async => testProduct);
      when(() => mockBox.keys).thenReturn([]);

      final result = await repository.addOrUpdateProduct(testProduct);

      expect(result.title, 'Test Product');
      verify(() => mockBox.add(testProduct)).called(1);
      verify(() => mockBox.put(0, testProduct)).called(1);
      verify(() => mockService.updateProduct(testProduct)).called(1);
    });

    test('addOrUpdateProduct updates product if existing', () async {
      // Ürün zaten var, key 0 olsun
      testProduct.hiveKey = 0;
      when(() => mockBox.put(0, testProduct)).thenAnswer((_) async {});
      when(
        () => mockService.updateProduct(testProduct),
      ).thenAnswer((_) async => testProduct);

      final result = await repository.addOrUpdateProduct(testProduct);

      expect(result.title, 'Test Product');
      verify(
        () => mockBox.put(0, testProduct),
      ).called(2); // önce güncelle, sonra service sonrası
      verify(() => mockService.updateProduct(testProduct)).called(1);
    });

    test('deleteProduct deletes product and calls service', () async {
      testProduct.hiveKey = 0;
      when(() => mockBox.delete(0)).thenAnswer((_) async {});
      when(
        () => mockService.deleteProduct(testProduct.id!),
      ).thenAnswer((_) async {});

      await repository.deleteProduct(testProduct);

      verify(() => mockBox.delete(0)).called(1);
      verify(() => mockService.deleteProduct(testProduct.id!)).called(1);
    });

    test('syncProducts adds new products from API', () async {
      final apiProducts = [testProduct];
      when(
        () => mockService.fetchProducts(),
      ).thenAnswer((_) async => apiProducts);
      when(() => mockBox.keys).thenReturn([]);
      when(() => mockBox.add(any<Product>())).thenAnswer((_) async => 0);
      when(
        () => mockBox.put(any<dynamic>(), any<Product>()),
      ).thenAnswer((_) async {});

      await repository.syncProducts();

      verify(() => mockBox.add(testProduct)).called(1);
      verifyNever(() => mockBox.put(any<dynamic>(), any<Product>()));
    });
  });
}
