import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class CitasProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _citas = [];
  List<dynamic> _medicos = [];
  Map<String, dynamic> _disponibilidad = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get citas => _citas;
  List<dynamic> get medicos => _medicos;
  Map<String, dynamic> get disponibilidad => _disponibilidad;

  Future<void> cargarCitas({
    int? pacienteId,
    int? medicoId,
    int? hospitalId,
    String? estado,
    String? fechaDesde,
    String? fechaHasta,
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (pacienteId != null) {
        queryParams['paciente_id'] = pacienteId.toString();
      }
      if (medicoId != null) queryParams['medico_id'] = medicoId.toString();
      if (hospitalId != null) {
        queryParams['hospital_id'] = hospitalId.toString();
      }
      if (estado != null) queryParams['estado'] = estado;
      if (fechaDesde != null) queryParams['fecha_desde'] = fechaDesde;
      if (fechaHasta != null) queryParams['fecha_hasta'] = fechaHasta;

      final response = await ApiService.get(
        '/api/citas',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _citas = data['citas'] ?? [];
        print('Citas cargadas: ${_citas.length}');
      } else {
        throw Exception('Error cargando citas: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en cargarCitas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarMedicos({String? especialidad}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (especialidad != null) queryParams['especialidad'] = especialidad;

      final response = await ApiService.get(
        '/api/medicos',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        _medicos = json.decode(response.body);
        print('Médicos cargados: ${_medicos.length}');
      } else {
        throw Exception('Error cargando médicos: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en cargarMedicos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> crearCita(Map<String, dynamic> citaData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('/api/citas', citaData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await cargarCitas(); // Recargar lista
        return json.decode(response.body);
      } else {
        throw Exception('Error creando cita: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en crearCita: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verificarDisponibilidad(
    int medicoId,
    String fecha, {
    int? hospitalId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{'fecha': fecha};
      if (hospitalId != null) {
        queryParams['hospital_id'] = hospitalId.toString();
      }

      final response = await ApiService.get(
        '/api/citas/medico/$medicoId/disponibilidad',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        _disponibilidad = json.decode(response.body);
        print('Disponibilidad cargada para médico $medicoId');
      } else {
        throw Exception(
          'Error verificando disponibilidad: ${response.statusCode}',
        );
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en verificarDisponibilidad: $e');
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
