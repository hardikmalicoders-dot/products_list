import 'package:products_list/core/constants/api_constants.dart';
import 'package:products_list/core/network/api_client.dart';
import 'package:products_list/data/models/product_model.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  ///TODO: Implement this method to fetch products list
  Future<ProductResponse> getProducts({
    required int limit,
    required int skip,
    String? token,
    String? searchQuery,
    String? category,
  }) async {
    String url = ApiConstants.products;
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'skip': skip.toString(),
    };

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      url = '${ApiConstants.products}/search';
      queryParams['q'] = searchQuery.trim();
    } else if (category != null && category.isNotEmpty && category != 'All') {
      url = '${ApiConstants.products}/category/$category';
    }

    final response = await _apiClient.get(
      url,
      queryParameters: queryParams,
      token: token,
    );

    return ProductResponse.fromJson(response as Map<String, dynamic>);
  }

  ///TODO: Implement this method to fetch product details
  Future<Product> getProductById(int id, {String? token}) async {
    final response = await _apiClient.get(
      '${ApiConstants.products}/$id',
      token: token,
    );
    return Product.fromJson(response as Map<String, dynamic>);
  }

  ///TODO: Implement this method to fetch categories list
  Future<List<String>> getCategories({String? token}) async {
    final response = await _apiClient.get(
      '${ApiConstants.products}/category-list',
      token: token,
    );
    if (response is List) {
      return response.map((e) => e.toString()).toList();
    }
    return [];
  }
}
