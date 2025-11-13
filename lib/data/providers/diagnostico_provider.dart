import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/diagnostico_model.dart';

class DiagnosticoProvider with ChangeNotifier {
  List<Diagnostico> _diagnosticos = [];
  DiagnosticoDetalle? _diagnosticoDetalle;
  bool _isLoading = false;
  bool _isLoadingHistorial = false;
  bool _isLoadingDetalle = false;
  String _errorMessage = '';

  bool _hasMore = true;

  List<Diagnostico> get diagnosticos => _diagnosticos;
  DiagnosticoDetalle? get diagnosticoDetalle => _diagnosticoDetalle;
  bool get isLoading => _isLoading;
  bool get isLoadingHistorial => _isLoadingHistorial;
  bool get isLoadingDetalle => _isLoadingDetalle;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> cargarHistorial({bool loadMore = false}) async {
    if (!loadMore) {
      _diagnosticos.clear();
      _hasMore = true;
    }

    _isLoadingHistorial = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/diagnosticos/historial');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('🔍 Response completo: $responseData');

        // formato de respuesta
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('diagnosticos')) {
            final diagnosticosList = (responseData['diagnosticos'] as List)
                .map((item) => Diagnostico.fromJson(item))
                .toList();

            if (loadMore) {
              _diagnosticos.addAll(diagnosticosList);
            } else {
              _diagnosticos = diagnosticosList;
            }

            // Debug de URLs
            print('🖼️ URLs de imágenes encontradas:');
            for (var i = 0; i < _diagnosticos.length; i++) {
              final diagnostico = _diagnosticos[i];
              print(
                '   ${i + 1}. ID ${diagnostico.id}: ${diagnostico.imagenOriginalUrl}',
              );
            }
          }
        }

        print('Historial cargado: ${_diagnosticos.length} diagnósticos');
      } else {
        throw Exception(
          'Error obteniendo historial: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _errorMessage = 'Error cargando historial: $e';
      print('Error en cargarHistorial: $e');
    } finally {
      _isLoadingHistorial = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> testUrlImagen(int diagnosticoId) async {
    try {
      final response = await ApiService.get(
        '/api/diagnosticos/test-url/$diagnosticoId',
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('Test URL Result: $result');
        return result;
      } else {
        throw Exception('Error testeando URL: ${response.statusCode}');
      }
    } catch (e) {
      print('Error testeando URL: $e');
      rethrow;
    }
  }

  Future<void> cargarMasDiagnosticos() async {
    if (_hasMore && !_isLoadingHistorial) {
      await cargarHistorial(loadMore: true);
    }
  }

  Future<void> cargarDetalleDiagnostico(int diagnosticoId) async {
    _isLoadingDetalle = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get(
        '/api/diagnosticos/detalle/$diagnosticoId',
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _diagnosticoDetalle = DiagnosticoDetalle.fromJson(jsonResponse);
        print('Detalle cargado para diagnóstico ID: $diagnosticoId');
      } else {
        throw Exception('Error obteniendo detalle: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error cargando detalle: $e';
      print('Error en cargarDetalleDiagnostico: $e');
      rethrow;
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  Future<AnalisisResponse> analizarImagen(File imagen) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.multipartRequest(
        '/api/diagnosticos/analizar',
        imagen,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final resultado = AnalisisResponse.fromJson(jsonResponse);

        // Recargar historial después del análisis
        await cargarHistorial();
        return resultado;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error analizando imagen');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiarDetalle() {
    _diagnosticoDetalle = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
