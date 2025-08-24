import 'package:app_test/repositories/product_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final bool refreshFromApi;
  LoadProducts({this.refreshFromApi = false});
}

class AddProductEvent extends ProductEvent {
  final Product product;
  AddProductEvent(this.product);
  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final Product product;
  UpdateProductEvent(this.product);
  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final Product product;
  DeleteProductEvent(this.product);
  @override
  List<Object?> get props => [product];
}

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        if (event.refreshFromApi) await repository.syncProducts();
        final products = repository.getLocalProducts();
        emit(ProductLoaded(products.reversed.toList()));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<AddProductEvent>((event, emit) async {
      try {
        await repository.addOrUpdateProduct(event.product);
        final products = repository.getLocalProducts();
        emit(ProductLoaded(products.reversed.toList()));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<UpdateProductEvent>((event, emit) async {
      try {
        await repository.addOrUpdateProduct(event.product);
        final products = repository.getLocalProducts();
        emit(ProductLoaded(products.reversed.toList()));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<DeleteProductEvent>((event, emit) async {
      try {
        await repository.deleteProduct(event.product);
        final products = repository.getLocalProducts();
        emit(ProductLoaded(products.reversed.toList()));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}
