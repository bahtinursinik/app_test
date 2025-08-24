import 'package:app_test/blocs/product_bloc.dart';
import 'package:app_test/models/product.dart';
import 'package:app_test/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ProductBloc bloc;
  late MockProductRepository repository;

  final sampleProduct1 = Product(
    id: 1,
    title: 'Product 1',
    price: 10.0,
    description: 'desc 1',
    category: 'cat 1',
  );

  final sampleProduct2 = Product(
    id: 2,
    title: 'Product 2',
    price: 20.0,
    description: 'desc 2',
    category: 'cat 2',
  );

  setUp(() {
    repository = MockProductRepository();
    bloc = ProductBloc(repository);
  });

  group('LoadProducts', () {
    test('başarılı → ProductLoaded döner', () async {
      when(
        () => repository.getLocalProducts(),
      ).thenReturn([sampleProduct1, sampleProduct2]);

      bloc.add(LoadProducts());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProductLoading>(),
          predicate<ProductLoaded>((state) {
            // reversed.toList() kontrolü
            return state.products[0].id == 2 && state.products[1].id == 1;
          }),
        ]),
      );
    });

    test('hata → ProductError döner', () async {
      when(() => repository.getLocalProducts()).thenThrow(Exception('fail'));

      bloc.add(LoadProducts());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProductLoading>(),
          predicate<ProductError>((state) => state.message.contains('fail')),
        ]),
      );
    });
  });

  group('AddProductEvent', () {
    test('başarılı → ProductLoaded döner', () async {
      final productToAdd = sampleProduct1;

      when(
        () => repository.addOrUpdateProduct(productToAdd),
      ).thenAnswer((_) async => productToAdd);
      when(() => repository.getLocalProducts()).thenReturn([productToAdd]);

      bloc.add(AddProductEvent(productToAdd));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductLoaded>(
            (state) => state.products.contains(productToAdd),
          ),
        ]),
      );
    });

    test('hata → ProductError döner', () async {
      final productToAdd = sampleProduct1;

      when(
        () => repository.addOrUpdateProduct(productToAdd),
      ).thenThrow(Exception('add fail'));

      bloc.add(AddProductEvent(productToAdd));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductError>(
            (state) => state.message.contains('add fail'),
          ),
        ]),
      );
    });
  });

  group('UpdateProductEvent', () {
    test('başarılı → ProductLoaded döner', () async {
      final productToUpdate = sampleProduct2;

      when(
        () => repository.addOrUpdateProduct(productToUpdate),
      ).thenAnswer((_) async => productToUpdate);
      when(() => repository.getLocalProducts()).thenReturn([productToUpdate]);

      bloc.add(UpdateProductEvent(productToUpdate));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductLoaded>(
            (state) => state.products.contains(productToUpdate),
          ),
        ]),
      );
    });

    test('hata → ProductError döner', () async {
      final productToUpdate = sampleProduct2;

      when(
        () => repository.addOrUpdateProduct(productToUpdate),
      ).thenThrow(Exception('update fail'));

      bloc.add(UpdateProductEvent(productToUpdate));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductError>(
            (state) => state.message.contains('update fail'),
          ),
        ]),
      );
    });
  });

  group('DeleteProductEvent', () {
    test('başarılı → ProductLoaded döner', () async {
      final productToDelete = sampleProduct1;

      when(
        () => repository.deleteProduct(productToDelete),
      ).thenAnswer((_) async => null);
      when(() => repository.getLocalProducts()).thenReturn([]);

      bloc.add(DeleteProductEvent(productToDelete));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductLoaded>((state) => state.products.isEmpty),
        ]),
      );
    });

    test('hata → ProductError döner', () async {
      final productToDelete = sampleProduct1;

      when(
        () => repository.deleteProduct(productToDelete),
      ).thenThrow(Exception('delete fail'));

      bloc.add(DeleteProductEvent(productToDelete));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductError>(
            (state) => state.message.contains('delete fail'),
          ),
        ]),
      );
    });
  });
}
