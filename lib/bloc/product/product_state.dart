import 'package:equatable/equatable.dart';
import 'package:products_list/core/constants/api_constants.dart';
import 'package:products_list/data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error, empty }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;
  final String? paginationError;
  final int total;
  final int skip;
  final int limit;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
    this.paginationError,
    this.total = 0,
    this.skip = 0,
    this.limit = ApiConstants.defaultLimit,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<String>? categories,
    String? Function()? selectedCategory,
    String? searchQuery,
    String? Function()? errorMessage,
    String? Function()? paginationError,
    int? total,
    int? skip,
    int? limit,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory != null ? selectedCategory() : this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      paginationError: paginationError != null ? paginationError() : this.paginationError,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        categories,
        selectedCategory,
        searchQuery,
        errorMessage,
        paginationError,
        total,
        skip,
        limit,
        isLoadingMore,
        isRefreshing,
        hasMore,
      ];
}
