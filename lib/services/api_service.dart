import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  String localdir = 'http://localhost:8000';
  String publicdir = 'https://backendalzheimer.onrender.com';
  static const String baseUrl = 'https://backendalzheimer.onrender.com';

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> get(String endpoint, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
