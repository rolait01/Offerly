import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:offerly/models/market_model.dart';
import 'package:offerly/services/market_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) onThemeToggle;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Market? selectedMarket;
  List<Market> markets = [];
  bool isLoadingLocation = false;
  final MarketService _marketService = MarketService();

  @override
  void initState() {
    super.initState();
    loadFromStorage();
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final marketData = prefs.getString('markets');
    final selected = prefs.getString('selectedMarket');

    if (marketData != null) {
      final List<dynamic> decoded = jsonDecode(marketData);
      markets = decoded.map((e) => Market.fromMap(e)).toList();
    }

    setState(() {
      selectedMarket = selected != null
          ? Market.fromMap(jsonDecode(selected))
          : (markets.isNotEmpty ? markets.first : null);
    });
  }

  Future<void> updateLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Standortdienst nicht aktiviert');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Standortberechtigung dauerhaft verweigert');
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String postalCode = placemarks.first.postalCode ?? '00000';
    debugPrint("[DEBUG] Postalcode: $postalCode");

    final newMarkets = await _marketService.fetchEdekaMarkets(postalCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'markets', jsonEncode(newMarkets.map((m) => m.toMap()).toList()));
    await prefs.setString(
        'selectedMarket', jsonEncode(newMarkets.first.toMap()));
    setState(() {
      markets = newMarkets;
      selectedMarket = newMarkets.first;
      isLoadingLocation = false;
    });
  }

  Future<void> updateSelectedMarket(Market? market) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMarket', jsonEncode(market?.toMap()));
    setState(() {
      selectedMarket = market;
      debugPrint("Selected Market: ${market?.address}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dunkles Design'),
            trailing: Switch(
              value: widget.isDarkMode,
              onChanged: widget.onThemeToggle,
            ),
            onTap: () => widget.onThemeToggle(!widget.isDarkMode),
          ),
          ListTile(
            leading: const Icon(Icons.auto_fix_high),
            title: const Text('Bias Booster'),
            trailing: const Switch(
              value: true,
              onChanged: null,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bias Booster ist immer aktiv. 😉'),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.lunch_dining),
            title: Text('Snack-Alarm'),
            trailing: Switch(
              value: true,
              onChanged: null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Standort aktualisieren'),
            trailing: isLoadingLocation
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: updateLocation,
                    child: const Text('Aktualisieren'),
                  ),
          ),
          if (markets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bevorzugter Edeka-Markt',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...markets.map((market) {
                    final isSelected =
                        selectedMarket?.angeboteUrl == market.angeboteUrl;
                    return GestureDetector(
                      onTap: () {
                        updateSelectedMarket(market);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Das Ändern eines Marktes kann bis zu einer Stunde dauern. Wir informieren dich, sobald dein Markt geändert wurde.'),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Stack(
                          children: [
                            // Glow hinter der Karte, nur sichtbar wenn ausgewählt
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Die eigentliche Karte
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Logo_Edeka.svg/43px-Logo_Edeka.svg.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            market.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            market.address,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
