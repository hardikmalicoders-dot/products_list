import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:products_list/bloc/product/product_bloc.dart';
import 'package:products_list/bloc/product/product_event.dart';
import 'package:products_list/bloc/product/product_state.dart';
import 'package:products_list/data/models/product_model.dart';
import 'package:products_list/data/repositories/product_repository.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockProductRepository;
  late Product testProduct1;
  late Product testProduct2;
  late ProductResponse testProductResponse;

  setUp(() {
    mockProductRepository = MockProductRepository();
    testProduct1 = Product(
      id: 1,
      title: 'Mascara',
      description: 'Volumizing mascara',
      category: 'beauty',
      price: 9.99,
      discountPercentage: 7.0,
      rating: 4.9,
      stock: 5,
      tags: ['beauty'],
      thumbnail: 'https://example.com/mascara.png',
      images: ['https://example.com/mascara.png'],
      reviews: [],
    );
    testProduct2 = Product(
      id: 2,
      title: 'Eyeshadow',
      description: 'Color palette',
      category: 'beauty',
      price: 19.99,
      discountPercentage: 10.0,
      rating: 4.5,
      stock: 12,
      tags: ['beauty'],
      thumbnail: 'https://example.com/eyeshadow.png',
      images: ['https://example.com/eyeshadow.png'],
      reviews: [],
    );
    testProductResponse = ProductResponse(
      products: [testProduct1, testProduct2],
      total: 2,
      skip: 0,
      limit: 15,
    );
  });

  group('ProductBloc', () {
    test('initial state is ProductState()', () {
      final productBloc = ProductBloc(productRepository: mockProductRepository);
      expect(productBloc.state, equals(const ProductState()));
      productBloc.close();
    });

    blocTest<ProductBloc, ProductState>(
      'emits [loading, loaded] when ProductFetchStarted succeeds',
      build: () {
        when(() => mockProductRepository.getProducts(
              limit: any(named: 'limit'),
              skip: any(named: 'skip'),
              token: any(named: 'token'),
              searchQuery: any(named: 'searchQuery'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => testProductResponse);
        return ProductBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(const ProductFetchStarted()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        ProductState(
          status: ProductStatus.loaded,
          products: [testProduct1, testProduct2],
          total: 2,
          skip: 2,
          hasMore: false,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [loading, empty] when ProductFetchStarted returns no products',
      build: () {
        when(() => mockProductRepository.getProducts(
              limit: any(named: 'limit'),
              skip: any(named: 'skip'),
              token: any(named: 'token'),
              searchQuery: any(named: 'searchQuery'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => ProductResponse(
              products: [],
              total: 0,
              skip: 0,
              limit: 15,
            ));
        return ProductBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(const ProductFetchStarted()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.empty,
          products: [],
          total: 0,
          skip: 0,
          hasMore: false,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [loading, error] when ProductFetchStarted fails',
      build: () {
        when(() => mockProductRepository.getProducts(
              limit: any(named: 'limit'),
              skip: any(named: 'skip'),
              token: any(named: 'token'),
              searchQuery: any(named: 'searchQuery'),
              category: any(named: 'category'),
            )).thenThrow(Exception('Network error'));
        return ProductBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(const ProductFetchStarted()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.error,
          errorMessage: 'Exception: Network error',
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits updated categories when ProductCategoriesFetchStarted succeeds',
      build: () {
        when(() => mockProductRepository.getCategories(token: any(named: 'token')))
            .thenAnswer((_) async => ['beauty', 'fragrances']);
        return ProductBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(const ProductCategoriesFetchStarted()),
      expect: () => [
        const ProductState(categories: ['All', 'beauty', 'fragrances']),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'resets state on ProductReset',
      build: () => ProductBloc(productRepository: mockProductRepository),
      seed: () => ProductState(
        status: ProductStatus.loaded,
        products: [testProduct1],
        total: 1,
      ),
      act: (bloc) => bloc.add(const ProductReset()),
      expect: () => [
        const ProductState(),
      ],
    );
  });
}
