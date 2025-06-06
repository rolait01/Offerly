import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:offerly/models/market_model.dart';

class MarketService {
  final String _baseUrl = 'http://192.168.178.130:8000';

  Future<List<Market>> fetchEdekaMarkets(String postalCode) async {
    final uri = Uri.parse('$_baseUrl/markets/edeka/$postalCode');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint("ANTWORT --------: $data");
        return data.map((json) => Market.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return []; // Keine Märkte gefunden
      } else {
        throw Exception('Fehler beim Laden der Märkte (Status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Server nicht erreichbar oder ungültige Antwort: $e');
    }
  }
}
