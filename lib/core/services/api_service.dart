import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String local = 'http://localhost:8000';
  static const String fisico = 'http://192.168.18.8:8000';
  static const String produccion = 'https://backendalzheimer.onrender.com';

  static String get baseUrl => _currentUrl;
  static String _currentUrl = fisico;

  static const String _urlKey = 'selectedBackendUrl';

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUrl = prefs.getString(_urlKey) ?? fisico;
  }

  static Future<void> changeBaseUrl(String newUrl) async {
    _currentUrl = newUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, newUrl);
  }

  static Map<String, String> getAvailableUrls() {
    return {'Local': local, 'Físico': fisico, 'Producción': produccion};
  }

  static String getCurrentUrlName() {
    final urls = getAvailableUrls();
    return urls.entries
        .firstWhere(
          (entry) => entry.value == _currentUrl,
          orElse: () => MapEntry('Personalizado', _currentUrl),
        )
        .key;
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final token = await _getToken();

    Uri uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    print('🔗 GET Request: $uri');

    return await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
  }

  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await _getToken();
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> multipartRequest(
    String endpoint,
    File imageFile,
  ) async {
    final token = await _getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: 'imagen_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
