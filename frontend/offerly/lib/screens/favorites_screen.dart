import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ProductService _productService = ProductService();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorites') ?? [];

    // Fetch product details for each favorite ID in parallel
    final products = await Future.wait(favoriteIds.map((id) async {
      // You need a method in your ProductService to fetch product by ID
      return _productService.fetchProductById(id);
    }));

    setState(() {
      _favoriteProducts = products.whereType<Product>().toList();
      _isLoading = false;
    });
  }

  void _removeItem(int index) async {
    final removedProduct = _favoriteProducts[index];
    final productId = removedProduct.id.toString();

    setState(() {
      _favoriteProducts.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedItem(removedProduct, animation),
        duration: const Duration(milliseconds: 300),
      );
    });

    // Update SharedPreferences as well
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    favorites.remove(productId);
    await prefs.setStringList('favorites', favorites);
  }

  Widget _buildRemovedItem(Product product, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: 0.0,
        child: ProductCard(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteProducts.isEmpty) {
      return const Center(child: Text('Keine Favoriten gefunden.'));
    }

    return AnimatedList(
      key: _listKey,
      initialItemCount: _favoriteProducts.length,
      itemBuilder: (context, index, animation) {
        final product = _favoriteProducts[index];
        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: 0.0,
          child: ProductCard(
            product: product,
            onFavoriteToggled: () {
              _removeItem(index);
            },
          ),
        );
      },
    );
  }
}
