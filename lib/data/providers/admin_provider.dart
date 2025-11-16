import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _historialCompleto = [];
  Map<String, dynamic> _estadisticasGlobales = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get historialCompleto => _historialCompleto;
  Map<String, dynamic> get estadisticasGlobales => _estadisticasGlobales;

  Future<void> cargarHistorialCompleto({
    int? pacienteId,
    String? fechaDesde,
    String? fechaHasta,
    String? resultado,
    int page = 1,
    int perPage = 10,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (pacienteId != null) {
        queryParams['paciente_id'] = pacienteId.toString();
      }
      if (fechaDesde != null) queryParams['fecha_desde'] = fechaDesde;
      if (fechaHasta != null) queryParams['fecha_hasta'] = fechaHasta;
      if (resultado != null) queryParams['resultado'] = resultado;

      final response = await ApiService.get(
        '/api/admin/historial-completo',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _historialCompleto = data['diagnosticos'] ?? [];
        print(
          'Historial completo cargado: ${_historialCompleto.length} registros',
        );
      } else {
        throw Exception(
          'Error cargando historial completo: ${response.statusCode}',
        );
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en cargarHistorialCompleto: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarEstadisticasGlobales() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/admin/estadisticas-globales');

      if (response.statusCode == 200) {
        _estadisticasGlobales = json.decode(response.body);
        print('Estadísticas globales cargadas');
      } else {
        throw Exception('Error cargando estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en cargarEstadisticasGlobales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
