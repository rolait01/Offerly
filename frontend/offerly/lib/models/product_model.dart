class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final String store;
  final double? score;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.store,
    this.score,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      store: map['store'] ?? '',
      score: _parseScore(map['score']),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'store': store,
      'score': score,
    };
  }

  static double? _parseScore(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
