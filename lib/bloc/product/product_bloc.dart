import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:products_list/data/models/product_model.dart';
import 'package:products_list/data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository(),
        super(const ProductState()) {
    on<ProductFetchStarted>(_onFetchStarted);
    on<ProductMoreFetched>(_onMoreFetched);
    on<ProductRefreshed>(_onRefreshed);
    on<ProductSearchChanged>(_onSearchChanged);
    on<ProductCategoryChanged>(_onCategoryChanged);
    on<ProductCategoriesFetchStarted>(_onCategoriesFetchStarted);
    on<ProductReset>(_onReset);
  }

  // Event handlers
  Future<void> _onFetchStarted(
    ProductFetchStarted event,
    Emitter<ProductState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(
        status: ProductStatus.loading,
        errorMessage: () => null,
      ));
    } else {
      emit(state.copyWith(isRefreshing: true));
    }

    try {
      final response = await _productRepository.getProducts(
        limit: state.limit,
        skip: 0,
        token: event.token,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
      );

      // Deduplicate response products by id
      final uniqueProducts = <Product>[];
      final seenIds = <int>{};
      for (final item in response.products) {
        if (seenIds.add(item.id)) {
          uniqueProducts.add(item);
        }
      }

      final hasMore = uniqueProducts.length < response.total;

      emit(state.copyWith(
        status: uniqueProducts.isEmpty ? ProductStatus.empty : ProductStatus.loaded,
        products: uniqueProducts,
        total: response.total,
        skip: uniqueProducts.length,
        hasMore: hasMore,
        isRefreshing: false,
        errorMessage: () => null,
        paginationError: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: () => e.toString(),
        isRefreshing: false,
      ));
    }
  }

  //TODO: Implement this method to handle more products fetch event
  Future<void> _onMoreFetched(
    ProductMoreFetched event,
    Emitter<ProductState> emit,
  ) async {
    if (state.isLoadingMore ||
        state.isRefreshing ||
        !state.hasMore ||
        state.status != ProductStatus.loaded) {
      return;
    }

    emit(state.copyWith(
      isLoadingMore: true,
      paginationError: () => null,
    ));

    try {
      final response = await _productRepository.getProducts(
        limit: state.limit,
        skip: state.skip,
        token: event.token,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
      );

      if (response.products.isNotEmpty) {
        final existingIds = state.products.map((p) => p.id).toSet();
        final newUniqueItems =
            response.products.where((p) => !existingIds.contains(p.id)).toList();

        if (newUniqueItems.isNotEmpty) {
          final updatedList = List<Product>.from(state.products)..addAll(newUniqueItems);
          final hasMore = updatedList.length < response.total;

          emit(state.copyWith(
            products: updatedList,
            skip: updatedList.length,
            total: response.total,
            hasMore: hasMore,
            isLoadingMore: false,
          ));
        } else {
          emit(state.copyWith(
            hasMore: false,
            isLoadingMore: false,
          ));
        }
      } else {
        emit(state.copyWith(
          hasMore: false,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        paginationError: () => e.toString(),
        isLoadingMore: false,
      ));
    }
  }

  //TODO: Implement this method to handle refresh event
  Future<void> _onRefreshed(
    ProductRefreshed event,
    Emitter<ProductState> emit,
  ) async {
    add(ProductFetchStarted(token: event.token, isRefresh: true));
  }

  // Event handlers
  void _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) {
    if (state.searchQuery == event.query) return;
    emit(state.copyWith(searchQuery: event.query));
    add(ProductFetchStarted(token: event.token));
  }

  void _onCategoryChanged(
    ProductCategoryChanged event,
    Emitter<ProductState> emit,
  ) {
    if (state.selectedCategory == event.category) return;
    emit(state.copyWith(selectedCategory: () => event.category));
    add(ProductFetchStarted(token: event.token));
  }

  //TODO: Implement this method to handle categories fetch event
  Future<void> _onCategoriesFetchStarted(
    ProductCategoriesFetchStarted event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final list = await _productRepository.getCategories(token: event.token);
      emit(state.copyWith(categories: ['All', ...list]));
    } catch (_) {}
  }

  // Event handlers
  void _onReset(
    ProductReset event,
    Emitter<ProductState> emit,
  ) {
    emit(const ProductState());
  }
}
