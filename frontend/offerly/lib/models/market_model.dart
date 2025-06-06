class Market {
  final String name;
  final String address;
  final String angeboteUrl;

  Market({
    required this.name,
    required this.address,
    required this.angeboteUrl,
  });

  factory Market.fromMap(Map<String, dynamic> map) {
    return Market(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      angeboteUrl: map['angebote_url'] ?? '',
    );
  }

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'angebote_url': angeboteUrl,
    };
  }
}
