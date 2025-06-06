import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'settings_screen.dart';

class ProductListScreen extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) onThemeToggle;

  const ProductListScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showError = false;

  bool _isLoading = false;
  List<Product> _products = [];
  Alignment _searchBarAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({required String query}) async {
    if (query.trim().isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _products = [];
      _showError = false;
      _searchBarAlignment = Alignment.topCenter;
    });

    try {
      final products = await _productService.fetchProducts(query);
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('FEHLER: $e');
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      setState(() {
        _showError = true;
      });
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _showError = false;
        _searchBarAlignment = Alignment.center;
      });
    } finally {
      if (!mounted) return;
    }
  }

  void _onSearchPressed() {
    FocusScope.of(context).unfocus(); // Tastatur schließen
    final text = _searchController.text.trim();
    debugPrint('TEXT: $text');
    if (text.isEmpty) {
      setState(() {
        _products.clear();
        _searchBarAlignment = Alignment.center;
      });
    } else {
      _loadProducts(query: text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          _buildErrorBanner(),
          AnimatedAlign(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: _searchBarAlignment,
            child: Padding(
              padding: EdgeInsets.only(
                top: _searchBarAlignment == Alignment.topCenter ? 30.0 : 0.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: _searchBarAlignment == Alignment.center,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 25.0),
                      child: Text(
                        'Suche nach Produkten',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Schokolade',
                      hintStyle: const WidgetStatePropertyAll(
                        TextStyle(
                          color: Colors.grey, // oder z.B. Colors.grey.shade600
                        ),
                      ),
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      trailing: [
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _onSearchPressed,
                        ),
                      ],
                      onSubmitted: (_) => _onSearchPressed(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 120),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: _products[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return AnimatedOpacity(
      opacity: _showError ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: _showError ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Server nicht erreichbar',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
