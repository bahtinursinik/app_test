import 'package:app_test/blocs/product_bloc.dart';
import 'package:app_test/service/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/product.dart';
import 'repositories/product_repository.dart';
import 'screens/product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive start
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  await Hive.openBox<Product>('products');

  // Repository ve service
  final shopService = ProductService();
  final productRepository = ProductRepository(shopService);

  runApp(MyApp(repository: productRepository));
}

class MyApp extends StatelessWidget {
  final ProductRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              ProductBloc(repository)..add(LoadProducts(refreshFromApi: true)),

      // create: (_) => ProductBloc(repository)..add(LoadProducts()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shoply',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const ProductScreen(),
      ),
    );
  }
}
