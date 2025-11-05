import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/diagnostico_model.dart';

class DiagnosticoProvider with ChangeNotifier {
  List<Diagnostico> _diagnosticos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Diagnostico> get diagnosticos => _diagnosticos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> cargarDiagnosticos() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get(
        '/api/diagnosticos/mis-diagnosticos',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _diagnosticos = data.map((json) => Diagnostico.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error obteniendo diagnósticos: ${response.statusCode}',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
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

        // Recargar lista después del análisis
        await cargarDiagnosticos();
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

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
