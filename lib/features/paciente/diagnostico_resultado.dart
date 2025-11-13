import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/diagnostico_model.dart';
import 'historial_diagnosticos.dart';

class DiagnosticoResultado extends StatelessWidget {
  final File imagen;
  final AnalisisResponse resultado;

  const DiagnosticoResultado({
    super.key,
    required this.imagen,
    required this.resultado,
  });

  Color _getColorByResult(String resultado) {
    switch (resultado) {
      case "Sin demencia":
        return Colors.green;
      case "Demencia muy leve":
        return Colors.orange;
      case "Demencia leve":
        return Colors.orangeAccent;
      case "Demencia moderada":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconByResult(String resultado) {
    switch (resultado) {
      case "Sin demencia":
        return Icons.check_circle;
      case "Demencia muy leve":
        return Icons.info;
      case "Demencia leve":
        return Icons.warning;
      case "Demencia moderada":
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  double _parseConfidence(String confianza) {
    try {
      String cleanConfidence = confianza.replaceAll('%', '').trim();
      return double.parse(cleanConfidence) / 100;
    } catch (e) {
      print('Error parseando confianza: $confianza');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidenceValue = _parseConfidence(resultado.confianza);

    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados del Análisis"),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _compartirResultados(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Tarjeta de resultado principal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconByResult(resultado.resultado),
                          color: _getColorByResult(resultado.resultado),
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Análisis Completado",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "ID: #${resultado.diagnosticoId}",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      resultado.resultado,
                      style: TextStyle(
                        color: _getColorByResult(resultado.resultado),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Confianza: ${resultado.confianza}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    _buildConfidenceBar(confidenceValue),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Tarjeta de imagen analizada
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.photo),
                    title: Text("Imagen Analizada"),
                    subtitle: Text("MRI Cerebral - ${_getFormattedDate()}"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        imagen,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 50, color: Colors.grey),
                                Text('Error cargando imagen'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  OverflowBar(
                    children: [
                      TextButton.icon(
                        onPressed: () => _verDetallesIA(context),
                        icon: Icon(Icons.analytics),
                        label: Text("Detalles IA"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Informacion adicional
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recomendaciones",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildRecommendationItem(
                      Icons.medical_services,
                      "Consulta con especialista",
                      "Programa cita con neurólogo para validación profesional",
                    ),
                    _buildRecommendationItem(
                      Icons.history,
                      "Seguimiento continuo",
                      "Realiza análisis periódicos cada 6-12 meses",
                    ),
                    _buildRecommendationItem(
                      Icons.people,
                      "Apoyo y comunicación",
                      "Mantén comunicación constante con tu cuidador y familia",
                    ),
                    _buildRecommendationItem(
                      Icons.self_improvement,
                      "Estilo de vida saludable",
                      "Ejercicio físico y mental, dieta balanceada",
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                    label: Text("Nuevo Análisis"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verHistorial(context),
                    icon: Icon(Icons.history),
                    label: Text("Ver Historial"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Nota
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Este análisis es asistido por IA y debe ser validado por un médico especialista.",
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nivel de Confianza del Análisis",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey[300],
          color: _getColorByResult(resultado.resultado),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Confianza del modelo IA",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              "${(confidence * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getColorByResult(resultado.resultado),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // AUXILIARES
  String _getFormattedDate() {
    return DateTime.now().toString().split(' ')[0];
  }

  void _verDetallesIA(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detalles del Análisis IA"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Resultado: ${resultado.resultado}"),
            Text("Confianza: ${resultado.confianza}"),
            SizedBox(height: 10),
            Text(
              "Modelo: CNN - Alzheimer Detection",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            if (resultado.datosRoboflow != null)
              Text(
                "Datos técnicos disponibles",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _verHistorial(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistorialDiagnosticos()),
    );
  }

  void _compartirResultados(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compartir resultados - En desarrollo')),
    );
  }
}
