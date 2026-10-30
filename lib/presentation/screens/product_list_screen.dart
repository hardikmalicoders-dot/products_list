import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      String? token;
      if (authState is AuthAuthenticated) {
        token = authState.accessToken;
      }

      context.read<ProductBloc>().add(ProductFetchStarted(token: token));
      context.read<ProductBloc>().add(ProductCategoriesFetchStarted(token: token));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? get _token {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.accessToken;
    }
    return null;
  }

  // Scroll listener to trigger pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final productState = context.read<ProductBloc>().state;

      if (productState.hasMore &&
          !productState.isLoadingMore &&
          !productState.isRefreshing) {
        context.read<ProductBloc>().add(ProductMoreFetched(token: _token));
      }
    }
  }

  // Logout logic
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(80, 36),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
      context.read<ProductBloc>().add(const ProductReset());

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Products'),
        leadingWidth: user != null ? 150 : null,
        leading: user != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: user.image.isNotEmpty
                          ? NetworkImage(user.image)
                          : null,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      child: user.image.isEmpty
                          ? Text(
                              user.firstName.isNotEmpty ? user.firstName[0] : 'U',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        user.firstName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductBloc>().add(
                                    ProductSearchChanged(query: '', token: _token),
                                  );
                            },
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    context.read<ProductBloc>().add(
                          ProductSearchChanged(query: value, token: _token),
                        );
                  },
                ),
              ),

              // Categories horizontal bar
              if (productState.categories.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: productState.categories.length,
                    itemBuilder: (context, index) {
                      final cat = productState.categories[index];
                      final isSelected =
                          (cat == 'All' && productState.selectedCategory == null) ||
                              productState.selectedCategory == cat;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(
                            cat[0].toUpperCase() + cat.substring(1),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade800,
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey.shade200,
                          onSelected: (selected) {
                            final newCategory = cat == 'All' ? null : cat;
                            context.read<ProductBloc>().add(
                                  ProductCategoryChanged(
                                      category: newCategory, token: _token),
                                );
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 8),

              // Product List Body States
              Expanded(
                child: _buildBody(context, productState),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductState productState,
  ) {
    switch (productState.status) {
      case ProductStatus.loading:
      case ProductStatus.initial:
        return const LoadingView(message: 'Fetching products...');

      case ProductStatus.error:
        return ErrorView(
          message: productState.errorMessage ?? 'Failed to load products.',
          onRetry: () {
            context.read<ProductBloc>().add(ProductFetchStarted(token: _token));
          },
        );

      case ProductStatus.empty:
        return EmptyView(
          title: 'No Products Found',
          message: productState.searchQuery.isNotEmpty
              ? 'No products matched "${productState.searchQuery}". Try a different term.'
              : 'There are no products available.',
          actionLabel: 'Clear Search',
          onAction: productState.searchQuery.isNotEmpty
              ? () {
                  _searchController.clear();
                  context.read<ProductBloc>().add(
                        ProductSearchChanged(query: '', token: _token),
                      );
                }
              : null,
        );

      case ProductStatus.loaded:
        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProductBloc>().add(ProductRefreshed(token: _token));
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount:
                productState.products.length + (productState.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < productState.products.length) {
                final product = productState.products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              } else {
                // Bottom loader or pagination error
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: productState.paginationError != null
                        ? Column(
                            children: [
                              Text(
                                'Error loading more: ${productState.paginationError}',
                                style:
                                    const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<ProductBloc>().add(
                                        ProductMoreFetched(token: _token),
                                      );
                                },
                                child: const Text('Retry Pagination'),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Loading more products (${productState.products.length}/${productState.total})...',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                  ),
                );
              }
            },
          ),
        );
    }
  }
}
