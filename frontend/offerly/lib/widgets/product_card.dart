import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onFavoriteToggled; // optional

  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteToggled,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      _isFavorite = favorites.contains(widget.product.id.toString());
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    final productId = widget.product.id.toString();

    if (_isFavorite) {
      favorites.remove(productId);
    } else {
      favorites.add(productId);
    }

    await prefs.setStringList('favorites', favorites);

    setState(() {
      _isFavorite = !_isFavorite;
    });
    // Call the callback if provided
    widget.onFavoriteToggled?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Titel + Herz in einer Zeile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.product.description.isNotEmpty)
                Text(
                  widget.product.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.product.price} €',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.product.store,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              if (widget.product.score != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Empfehlung: ${(widget.product.score!).toStringAsFixed(0)} %',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.yellowAccent.shade100,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
