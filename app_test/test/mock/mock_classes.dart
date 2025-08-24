import 'package:app_test/service/product_service.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockProductService extends Mock implements ProductService {}

class MockBox<T> extends Mock implements Box<T> {}
