import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/diagnostico.dart';

class DiagnosticoService {
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('authToken');
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  static Future<AnalisisResponse> analizarImagen(File imageFile) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión nuevamente.');
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/diagnosticos/analizar'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: 'imagen_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      print('Enviando imagen al backend...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AnalisisResponse.fromJson(jsonResponse);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error analizando imagen');
      }
    } catch (e) {
      print('Error en analizarImagen: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<Diagnostico>> obtenerMisDiagnosticos() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await ApiService.get(
        '/api/diagnosticos/mis-diagnosticos',
        token,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Diagnostico.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error obteniendo diagnósticos: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en obtenerMisDiagnosticos: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Diagnostico> obtenerDiagnostico(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await ApiService.get('/api/diagnosticos/$id', token);

      if (response.statusCode == 200) {
        return Diagnostico.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error obteniendo diagnóstico: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerDiagnostico: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
