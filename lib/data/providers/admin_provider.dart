import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../models/dashboard_models.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _historialCompleto = [];
  Map<String, dynamic> _estadisticasGlobales = {};

  // Datos del Dashboard
  DashboardCompleto? _dashboardCompleto;
  EstadisticasGenerales? _estadisticasGenerales;
  List<DiagnosticoPorClasificacion> _diagnosticosPorClasificacion = [];
  List<CitasPorHospital> _citasPorHospital = [];
  List<PacienteDetallado> _pacientesDestacados = [];
  List<MedicoEstadisticas> _medicosEstadisticas = [];
  List<ActividadReciente> _actividadReciente = [];
  List<DiagnosticosPorMes> _tendenciasMensuales = [];

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get historialCompleto => _historialCompleto;
  Map<String, dynamic> get estadisticasGlobales => _estadisticasGlobales;

  DashboardCompleto? get dashboardCompleto => _dashboardCompleto;
  EstadisticasGenerales? get estadisticasGenerales => _estadisticasGenerales;
  List<DiagnosticoPorClasificacion> get diagnosticosPorClasificacion =>
      _diagnosticosPorClasificacion;
  List<CitasPorHospital> get citasPorHospital => _citasPorHospital;
  List<PacienteDetallado> get pacientesDestacados => _pacientesDestacados;
  List<MedicoEstadisticas> get medicosEstadisticas => _medicosEstadisticas;
  List<ActividadReciente> get actividadReciente => _actividadReciente;
  List<DiagnosticosPorMes> get tendenciasMensuales => _tendenciasMensuales;

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

  // ==================== MÉTODOS DEL DASHBOARD ====================

  /// Obtener dashboard completo con todas las estadísticas
  Future<void> cargarDashboardCompleto() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/dashboard/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _dashboardCompleto = DashboardCompleto.fromJson(data);

        // Actualizar también las propiedades individuales
        _estadisticasGenerales = _dashboardCompleto!.estadisticasGenerales;
        _diagnosticosPorClasificacion = _dashboardCompleto!.diagnosticosPorClasificacion;
        _citasPorHospital = _dashboardCompleto!.citasPorHospital;
        _pacientesDestacados = _dashboardCompleto!.pacientesDestacados;
        _medicosEstadisticas = _dashboardCompleto!.medicosEstadisticas;
        _actividadReciente = _dashboardCompleto!.actividadReciente;
        _tendenciasMensuales = _dashboardCompleto!.tendenciasMensuales;

        print('✅ Dashboard cargado: ${_estadisticasGenerales?.totalUsuarios ?? 0} usuarios, ${_estadisticasGenerales?.totalDiagnosticos ?? 0} diagnósticos');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Error cargando dashboard: $e';
      print('❌ Error en cargarDashboardCompleto: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener solo estadísticas generales
  Future<void> cargarEstadisticasGeneralesDashboard() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/dashboard/estadisticas-generales');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _estadisticasGenerales = EstadisticasGenerales.fromJson(data);
        print('✅ Estadísticas generales cargadas');
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('❌ Error en cargarEstadisticasGeneralesDashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener diagnósticos por clasificación
  Future<void> cargarDiagnosticosPorClasificacion() async {
    try {
      final response = await ApiService.get('/api/dashboard/diagnosticos-clasificacion');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _diagnosticosPorClasificacion = data
            .map((e) => DiagnosticoPorClasificacion.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error en cargarDiagnosticosPorClasificacion: $e');
    }
  }

  /// Obtener citas por hospital
  Future<void> cargarCitasPorHospital() async {
    try {
      final response = await ApiService.get('/api/dashboard/citas-hospital');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _citasPorHospital = data
            .map((e) => CitasPorHospital.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error en cargarCitasPorHospital: $e');
    }
  }

  /// Obtener pacientes detallados
  Future<void> cargarPacientesDestacados({int limit = 10}) async {
    try {
      final response = await ApiService.get(
        '/api/dashboard/pacientes',
        queryParams: {'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _pacientesDestacados = data
            .map((e) => PacienteDetallado.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error en cargarPacientesDestacados: $e');
    }
  }

  /// Obtener estadísticas de médicos
  Future<void> cargarMedicosEstadisticas({int limit = 10}) async {
    try {
      final response = await ApiService.get(
        '/api/dashboard/medicos',
        queryParams: {'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _medicosEstadisticas = data
            .map((e) => MedicoEstadisticas.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error en cargarMedicosEstadisticas: $e');
    }
  }

  /// Obtener actividad reciente
  Future<void> cargarActividadReciente({int limit = 20}) async {
    try {
      final response = await ApiService.get(
        '/api/dashboard/actividad-reciente',
        queryParams: {'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _actividadReciente = data
            .map((e) => ActividadReciente.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error en cargarActividadReciente: $e');
    }
  }

  /// Obtener tendencias mensuales
  Future<void> cargarTendenciasMensuales({int meses = 6}) async {
    try {
      final response = await ApiService.get(
        '/api/dashboard/tendencias-mensuales',
        queryParams: {'meses': meses.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _tendenciasMensuales = data
            .map((e) => DiagnosticosPorMes.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error en cargarTendenciasMensuales: $e');
    }
  }

  /// Obtener estadísticas personalizadas con filtros de fecha
  Future<Map<String, dynamic>> cargarEstadisticasPersonalizadas({
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio;
      if (fechaFin != null) queryParams['fecha_fin'] = fechaFin;

      final response = await ApiService.get(
        '/api/dashboard/estadisticas-personalizadas',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('❌ Error en cargarEstadisticasPersonalizadas: $e');
      return {};
    }
  }
}
