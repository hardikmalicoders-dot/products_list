import 'package:flutter/foundation.dart';
import 'package:products_list/core/constants/api_constants.dart';
import 'package:products_list/data/models/product_model.dart';
import 'package:products_list/data/repositories/product_repository.dart';

enum ProductStateStatus { initial, loading, loaded, error, empty }

class ProductProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  ProductProvider({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository();

  ProductStateStatus _status = ProductStateStatus.initial;
  ProductStateStatus get status => _status;

  List<Product> _products = [];
  List<Product> get products => _products;

  List<String> _categories = [];
  List<String> get categories => _categories;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Pagination & Refresh states
  int _total = 0;
  int get total => _total;

  int _skip = 0;
  int get skip => _skip;

  final int _limit = ApiConstants.defaultLimit;
  int get limit => _limit;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _paginationError;
  String? get paginationError => _paginationError;

  // Initial products fetch / Refresh
  Future<void> fetchProducts({
    String? token,
    bool isRefresh = false,
  }) async {
    _isRefreshing = isRefresh;
    if (!isRefresh) {
      _status = ProductStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    _skip = 0;
    _hasMore = true;
    _paginationError = null;

    try {
      final response = await _productRepository.getProducts(
        limit: _limit,
        skip: 0,
        token: token,
        searchQuery: _searchQuery,
        category: _selectedCategory,
      );

      // Deduplicate response products by id
      final uniqueProducts = <Product>[];
      final seenIds = <int>{};
      for (final item in response.products) {
        if (seenIds.add(item.id)) {
          uniqueProducts.add(item);
        }
      }

      _products = uniqueProducts;
      _total = response.total;
      _skip = _products.length;
      _hasMore = _products.length < _total;

      if (_products.isEmpty) {
        _status = ProductStateStatus.empty;
      } else {
        _status = ProductStateStatus.loaded;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProductStateStatus.error;
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // Fetch next page for pagination
  Future<void> fetchMoreProducts({String? token}) async {
    if (_isLoadingMore || _isRefreshing || !_hasMore || _status != ProductStateStatus.loaded) {
      return;
    }

    _isLoadingMore = true;
    _paginationError = null;
    notifyListeners();

    try {
      final response = await _productRepository.getProducts(
        limit: _limit,
        skip: _skip,
        token: token,
        searchQuery: _searchQuery,
        category: _selectedCategory,
      );

      if (response.products.isNotEmpty) {
        // Deduplicate new products against existing items in _products
        final existingIds = _products.map((p) => p.id).toSet();
        final newUniqueItems = response.products.where((p) => !existingIds.contains(p.id)).toList();

        if (newUniqueItems.isNotEmpty) {
          _products.addAll(newUniqueItems);
          _skip = _products.length;
          _hasMore = _products.length < response.total;
          _total = response.total;
        } else {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _paginationError = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Pull to refresh
  Future<void> refreshProducts({String? token}) async {
    await fetchProducts(token: token, isRefresh: true);
  }

  // Search filter
  void setSearchQuery(String query, {String? token}) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    fetchProducts(token: token);
  }

  // Category filter
  void setCategory(String? category, {String? token}) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchProducts(token: token);
  }

  // Fetch categories list
  Future<void> fetchCategories({String? token}) async {
    try {
      final list = await _productRepository.getCategories(token: token);
      _categories = ['All', ...list];
      notifyListeners();
    } catch (_) {}
  }

  // Reset product state on logout
  void reset() {
    _status = ProductStateStatus.initial;
    _products = [];
    _categories = [];
    _selectedCategory = null;
    _searchQuery = '';
    _errorMessage = null;
    _skip = 0;
    _total = 0;
    _hasMore = true;
    _isLoadingMore = false;
    _isRefreshing = false;
    _paginationError = null;
    notifyListeners();
  }
}
