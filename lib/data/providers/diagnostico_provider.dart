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

  // Paginación
  int _currentPage = 1;
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
      _currentPage = 1;
      _diagnosticos.clear();
      _hasMore = true;
    }

    if (!_hasMore && loadMore) return;

    _isLoadingHistorial = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get(
        '/api/diagnosticos/historial',
        queryParams: {'page': _currentPage.toString(), 'per_page': '10'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Manejar diferentes formatos de respuesta
        if (responseData is Map<String, dynamic>) {
          // Si es un mapa, asumimos que es el formato de historial
          final historialResponse = HistorialResponse.fromJson(responseData);

          if (loadMore) {
            _diagnosticos.addAll(historialResponse.diagnosticos);
          } else {
            _diagnosticos = historialResponse.diagnosticos;
          }

          _currentPage = historialResponse.pagination.page;
          _hasMore = historialResponse.pagination.hasNext;
        } else if (responseData is List) {
          // Si es una lista directa (formato antiguo)
          final diagnosticosList = (responseData)
              .map((item) => Diagnostico.fromJson(item))
              .toList();

          if (loadMore) {
            _diagnosticos.addAll(diagnosticosList);
          } else {
            _diagnosticos = diagnosticosList;
          }

          _hasMore =
              diagnosticosList.length >=
              10; // Asumir que hay más si llegamos al límite
        }

        print('✅ Historial cargado: ${_diagnosticos.length} diagnósticos');
      } else {
        throw Exception(
          'Error obteniendo historial: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _errorMessage = 'Error cargando historial: $e';
      print('❌ Error en cargarHistorial: $e');
    } finally {
      _isLoadingHistorial = false;
      notifyListeners();
    }
  }

  Future<void> cargarMasDiagnosticos() async {
    if (_hasMore && !_isLoadingHistorial) {
      _currentPage++;
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
        print('✅ Detalle cargado para diagnóstico ID: $diagnosticoId');
      } else {
        throw Exception('Error obteniendo detalle: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error cargando detalle: $e';
      print('❌ Error en cargarDetalleDiagnostico: $e');
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
