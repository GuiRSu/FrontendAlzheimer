class Diagnostico {
  final int id;
  final int pacienteId;
  final String resultado;
  final double confianza;
  final String? claseOriginal;
  final String? imagenOriginalUrl;
  final String? imagenProcesadaUrl;
  final Map<String, dynamic>? datosRoboflow;
  final String estado;
  final DateTime createdAt;

  Diagnostico({
    required this.id,
    required this.pacienteId,
    required this.resultado,
    required this.confianza,
    this.claseOriginal,
    this.imagenOriginalUrl,
    this.imagenProcesadaUrl,
    this.datosRoboflow,
    required this.estado,
    required this.createdAt,
  });

  factory Diagnostico.fromJson(Map<String, dynamic> json) {
    return Diagnostico(
      id: json['id'] ?? 0,
      pacienteId: json['paciente_id'] ?? 0,
      resultado: json['resultado'] ?? 'Sin resultado',
      confianza: (json['confianza'] ?? 0.0).toDouble(),
      claseOriginal: json['clase_original'],
      imagenOriginalUrl: json['imagen_original_url'],
      imagenProcesadaUrl: json['imagen_procesada_url'],
      datosRoboflow: json['datos_roboflow'],
      estado: json['estado'] ?? 'completado',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toString(),
      ),
    );
  }

  String get fechaFormateada {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get horaFormateada {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

class AnalisisResponse {
  final String resultado;
  final String confianza;
  final int diagnosticoId;
  final Map<String, dynamic>? datosRoboflow;

  AnalisisResponse({
    required this.resultado,
    required this.confianza,
    required this.diagnosticoId,
    this.datosRoboflow,
  });

  factory AnalisisResponse.fromJson(Map<String, dynamic> json) {
    return AnalisisResponse(
      resultado: json['resultado'] ?? 'Sin resultado',
      confianza: json['confianza'] ?? '0%',
      diagnosticoId: json['diagnostico_id'] ?? 0,
      datosRoboflow: json['datos_roboflow'],
    );
  }
}

class HistorialResponse {
  final List<Diagnostico> diagnosticos;
  final PaginationInfo pagination;

  HistorialResponse({required this.diagnosticos, required this.pagination});

  factory HistorialResponse.fromJson(Map<String, dynamic> json) {
    return HistorialResponse(
      diagnosticos: ((json['diagnosticos'] ?? []) as List)
          .map((item) => Diagnostico.fromJson(item))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

class DiagnosticoDetalle {
  final int id;
  final DateTime fechaAnalisis;
  final String resultado;
  final double confianza;
  final String claseOriginal;
  final String imagenOriginalUrl;
  final String? imagenProcesadaUrl;
  final String estado;
  final DatosDetallados datosDetallados;

  DiagnosticoDetalle({
    required this.id,
    required this.fechaAnalisis,
    required this.resultado,
    required this.confianza,
    required this.claseOriginal,
    required this.imagenOriginalUrl,
    this.imagenProcesadaUrl,
    required this.estado,
    required this.datosDetallados,
  });

  factory DiagnosticoDetalle.fromJson(Map<String, dynamic> json) {
    return DiagnosticoDetalle(
      id: json['id'] ?? 0,
      fechaAnalisis: DateTime.parse(
        json['fecha_analisis'] ?? DateTime.now().toString(),
      ),
      resultado: json['resultado'] ?? 'Sin resultado',
      confianza: (json['confianza'] ?? 0.0).toDouble(),
      claseOriginal: json['clase_original'] ?? 'No especificada',
      imagenOriginalUrl: json['imagen_original_url'] ?? '',
      imagenProcesadaUrl: json['imagen_procesada_url'],
      estado: json['estado'] ?? 'completado',
      datosDetallados: DatosDetallados.fromJson(json['datos_detallados'] ?? {}),
    );
  }
}

class DatosDetallados {
  final List<PrediccionDetalle> predicciones;
  final Map<String, dynamic> metadatosImagen;
  final Map<String, dynamic> estadisticas;

  DatosDetallados({
    required this.predicciones,
    required this.metadatosImagen,
    required this.estadisticas,
  });

  factory DatosDetallados.fromJson(Map<String, dynamic> json) {
    return DatosDetallados(
      predicciones: ((json['predicciones'] ?? []) as List)
          .map((item) => PrediccionDetalle.fromJson(item))
          .toList(),
      metadatosImagen: json['metadatos_imagen'] ?? {},
      estadisticas: json['estadisticas'] ?? {},
    );
  }
}

class PrediccionDetalle {
  final String clase;
  final double confianza;
  final int? claseId;
  final Map<String, dynamic>? bbox;

  PrediccionDetalle({
    required this.clase,
    required this.confianza,
    this.claseId,
    this.bbox,
  });

  factory PrediccionDetalle.fromJson(Map<String, dynamic> json) {
    return PrediccionDetalle(
      clase: json['clase'] ?? 'Desconocida',
      confianza: (json['confianza'] ?? 0.0).toDouble(),
      claseId: json['clase_id'],
      bbox: json['bbox'],
    );
  }
}
