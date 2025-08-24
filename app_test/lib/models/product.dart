import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject with EquatableMixin {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? category;

  @HiveField(5)
  int? hiveKey;

  Product({
    this.id,
    required this.title,
    required this.price,
    this.description,
    this.category,
    this.hiveKey,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    title: json['title'],
    price: (json['price'] as num).toDouble(),
    description: json['description'],
    category: json['category'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
  };

  @override
  List<Object?> get props => [id, title, price, description, category, hiveKey];
}
