import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductFetchStarted extends ProductEvent {
  final String? token;
  final bool isRefresh;

  const ProductFetchStarted({this.token, this.isRefresh = false});

  @override
  List<Object?> get props => [token, isRefresh];
}

class ProductMoreFetched extends ProductEvent {
  final String? token;

  const ProductMoreFetched({this.token});

  @override
  List<Object?> get props => [token];
}

class ProductRefreshed extends ProductEvent {
  final String? token;

  const ProductRefreshed({this.token});

  @override
  List<Object?> get props => [token];
}

class ProductSearchChanged extends ProductEvent {
  final String query;
  final String? token;

  const ProductSearchChanged({required this.query, this.token});

  @override
  List<Object?> get props => [query, token];
}

class ProductCategoryChanged extends ProductEvent {
  final String? category;
  final String? token;

  const ProductCategoryChanged({this.category, this.token});

  @override
  List<Object?> get props => [category, token];
}

class ProductCategoriesFetchStarted extends ProductEvent {
  final String? token;

  const ProductCategoriesFetchStarted({this.token});

  @override
  List<Object?> get props => [token];
}

class ProductReset extends ProductEvent {
  const ProductReset();
}
