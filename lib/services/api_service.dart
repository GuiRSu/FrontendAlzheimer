import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String local = 'http://localhost:8000';
  static const String fisico = 'http://192.168.18.8:8000';
  static const String produccion = 'https://backendalzheimer.onrender.com';

  static String baseUrl = fisico;

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
