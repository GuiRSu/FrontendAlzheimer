class Diagnostico {
  final int id;
  final int pacienteId;
  final String? imagenUrl;
  final String? resultadoIa;
  final double? confianzaIa;
  final String? notasMedico;
  final String estado;
  final DateTime createdAt;

  Diagnostico({
    required this.id,
    required this.pacienteId,
    this.imagenUrl,
    this.resultadoIa,
    this.confianzaIa,
    this.notasMedico,
    required this.estado,
    required this.createdAt,
  });

  factory Diagnostico.fromJson(Map<String, dynamic> json) {
    return Diagnostico(
      id: json['id'],
      pacienteId: json['paciente_id'],
      imagenUrl: json['imagen_url'],
      resultadoIa: json['resultado_ia'],
      confianzaIa: json['confianza_ia']?.toDouble(),
      notasMedico: json['notas_medico'],
      estado: json['estado'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class AnalisisResponse {
  final String resultado;
  final String confianza;
  final String? outputImage;
  final String? dynamicCrop;
  final int diagnosticoId;

  AnalisisResponse({
    required this.resultado,
    required this.confianza,
    this.outputImage,
    this.dynamicCrop,
    required this.diagnosticoId,
  });

  factory AnalisisResponse.fromJson(Map<String, dynamic> json) {
    return AnalisisResponse(
      resultado: json['resultado'],
      confianza: json['confianza'],
      outputImage: json['output_image'],
      dynamicCrop: json['dynamic_crop'],
      diagnosticoId: json['diagnostico_id'],
    );
  }
}
