import 'package:app_test/blocs/product_bloc.dart';
import 'package:app_test/models/product.dart';
import 'package:app_test/widgets/product_card.dart';
import 'package:app_test/widgets/product_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductBloc extends Mock implements ProductBloc {
  @override
  Future<void> close() async {
    return;
  }
}

void main() {
  late ProductBloc productBloc;

  setUp(() {
    productBloc = MockProductBloc();
  });

  Widget createProductCard(Product product) {
    return MaterialApp(
      home: BlocProvider.value(
        value: productBloc,
        child: ProductCard(product: product),
      ),
    );
  }

  Widget createFormDialog({Product? product, bool isUpdate = false}) {
    return MaterialApp(
      home: BlocProvider.value(
        value: productBloc,
        child: Builder(
          builder:
              (context) => ElevatedButton(
                child: const Text("Open Dialog"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => ProductFormDialog(
                          product: product,
                          isUpdate: isUpdate,
                        ),
                  );
                },
              ),
        ),
      ),
    );
  }

  group('ProductCard Widget Tests', () {
    final sampleProduct = Product(
      id: 1,
      title: "Sample",
      price: 50,
      description: "Sample desc",
      category: "Kitap",
    );

    testWidgets('displays product info correctly', (tester) async {
      await tester.pumpWidget(createProductCard(sampleProduct));

      expect(find.text("Sample"), findsOneWidget);
      expect(find.text("50.00 \$"), findsOneWidget);
      expect(find.text("Sample desc"), findsOneWidget);
      expect(find.text("Kitap"), findsOneWidget);
    });

    testWidgets('tapping edit button opens ProductFormDialog', (tester) async {
      await tester.pumpWidget(createProductCard(sampleProduct));

      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.byType(ProductFormDialog), findsOneWidget);
      expect(find.text('Update Product'), findsOneWidget);
    });

    testWidgets('tapping delete button shows confirmation dialog', (
      tester,
    ) async {
      await tester.pumpWidget(createProductCard(sampleProduct));

      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to delete this product?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('ProductFormDialog Widget Tests', () {
    testWidgets('shows all input fields correctly', (tester) async {
      await tester.pumpWidget(createFormDialog());

      await tester.tap(find.text("Open Dialog"));
      await tester.pumpAndSettle();

      expect(
        find.byType(TextFormField),
        findsNWidgets(3),
      ); // title, price, description
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Add Product'), findsOneWidget);
    });

    testWidgets('shows custom category field when "Other" is selected', (
      tester,
    ) async {
      await tester.pumpWidget(createFormDialog());

      await tester.tap(find.text("Open Dialog"));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();

      expect(
        find.byType(TextFormField),
        findsNWidgets(4),
      ); // custom category dahil
      expect(find.text('Custom Category'), findsOneWidget);
    });
  });
}
