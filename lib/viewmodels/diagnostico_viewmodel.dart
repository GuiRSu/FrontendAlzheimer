import 'dart:io';
import 'package:flutter/material.dart';
import '../services/diagnostico_service.dart';
import '../models/diagnostico.dart';

class DiagnosticoViewModel with ChangeNotifier {
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
      _diagnosticos = await DiagnosticoService.obtenerMisDiagnosticos();
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
      final resultado = await DiagnosticoService.analizarImagen(imagen);
      // Recargar lista
      await cargarDiagnosticos();
      return resultado;
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
