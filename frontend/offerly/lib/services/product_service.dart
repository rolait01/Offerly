// services/product_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final String _baseUrl = 'http://192.168.xxx.xxx:8000';

  Future<List<Product>> fetchProducts(String query) async {
    debugPrint("Send request with $query");
    final uri =
        Uri.parse('$_baseUrl/search?productName=${Uri.encodeComponent(query)}');
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    try {
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Fehler beim Laden der Produkte');
      }
    } on SocketException {
      debugPrint('❌ SocketException: Backend nicht erreichbar');
      throw Exception('Server nicht erreichbar');
    } catch (e) {
      debugPrint('❌ Unbekannter Fehler: $e');
      throw Exception('Unbekannter Fehler beim Laden');
    }
  }

  Future<Product?> fetchProductById(String id) async {
    final uri = Uri.parse('$_baseUrl/product/$id');
    final response = await http.get(uri);
    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Product not found
      } else {
        throw Exception('Fehler beim Laden des Produkts');
      }
    } catch (e) {
      throw Exception('Server nicht erreichbar');
    }
  }

  Future<List<Product>> fetchProductsByAI(String query) async {
    debugPrint("Send request with $query");
    final uri =
        Uri.parse('$_baseUrl/AIsearch?productName=${Uri.encodeComponent(query)}');
    final response = await http.get(uri).timeout(const Duration(seconds: 30));
    try {
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint("RESPONSE: $data");
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Fehler beim Laden der Produkte');
      }
    } on SocketException {
      debugPrint('❌ SocketException: Backend nicht erreichbar');
      throw Exception('Server nicht erreichbar');
    } catch (e) {
      debugPrint('❌ Unbekannter Fehler: $e');
      throw Exception('Unbekannter Fehler beim Laden');
    }
  }
}
