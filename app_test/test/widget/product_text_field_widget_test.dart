import 'package:app_test/widgets/product_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductTextField Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('shows label correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductTextField(controller: controller, label: 'Test Label'),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('accepts input and updates controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductTextField(controller: controller, label: 'Input Test'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello Flutter');
      expect(controller.text, 'Hello Flutter');
    });

    testWidgets('validator works correctly', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: ProductTextField(
                controller: controller,
                label: 'Required Field',
              ),
            ),
          ),
        ),
      );
      bool valid = formKey.currentState!.validate();
      expect(valid, false);

      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Valid Input');

      valid = formKey.currentState!.validate();
      await tester.pump();
      expect(valid, true);

      expect(find.text('This field is required'), findsNothing);
    });
  });
}
