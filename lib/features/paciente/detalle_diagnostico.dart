import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/diagnostico_provider.dart';
import '../../data/models/diagnostico_model.dart';

class DetalleDiagnostico extends StatefulWidget {
  final int diagnosticoId;

  const DetalleDiagnostico({super.key, required this.diagnosticoId});

  @override
  _DetalleDiagnosticoState createState() => _DetalleDiagnosticoState();
}

class _DetalleDiagnosticoState extends State<DetalleDiagnostico> {
  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  void _cargarDetalle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DiagnosticoProvider>(context, listen: false);
      provider.cargarDetalleDiagnostico(widget.diagnosticoId);
    });
  }

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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Diagnóstico'),
        backgroundColor: const Color.fromARGB(255, 179, 219, 252),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDetalle,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Consumer<DiagnosticoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetalle) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return _buildErrorWidget(provider);
          }

          final diagnostico = provider.diagnosticoDetalle;
          if (diagnostico == null) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () =>
                provider.cargarDetalleDiagnostico(widget.diagnosticoId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildResultadoCard(diagnostico),
                const SizedBox(height: 20),
                _buildImagenesSection(diagnostico), // Solo imagen original
                const SizedBox(height: 20),
                _buildDetallesTecnicos(diagnostico),
                const SizedBox(height: 20),
                _buildPrediccionesSection(diagnostico),
                const SizedBox(height: 20),
                _buildNotaImportante(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultadoCard(DiagnosticoDetalle diagnostico) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getColorByResult(
                      diagnostico.resultado,
                    ).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconByResult(diagnostico.resultado),
                    color: _getColorByResult(diagnostico.resultado),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diagnóstico',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        diagnostico.resultado,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getColorByResult(diagnostico.resultado),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetrica(
                  'Confianza',
                  '${diagnostico.confianza.toStringAsFixed(1)}%',
                  Icons.analytics,
                ),
                _buildMetrica(
                  'Fecha',
                  _formatearFecha(diagnostico.fechaAnalisis),
                  Icons.calendar_today,
                ),
                _buildMetrica('Estado', diagnostico.estado, Icons.verified),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetrica(String titulo, String valor, IconData icono) {
    return Column(
      children: [
        Icon(icono, size: 20, color: Colors.blue),
        const SizedBox(height: 8),
        Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          valor,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildImagenesSection(DiagnosticoDetalle diagnostico) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Imagen del Análisis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Solo imagen original
            _buildImagenItem(
              'Imagen Original Subida',
              diagnostico.imagenOriginalUrl,
              Icons.photo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagenItem(String titulo, String url, IconData icono) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Error cargando imagen',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetallesTecnicos(DiagnosticoDetalle diagnostico) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles Técnicos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetalleItem('Clase Original', diagnostico.claseOriginal),
            _buildDetalleItem('ID del Diagnóstico', diagnostico.id.toString()),
            _buildDetalleItem(
              'Fecha de Análisis',
              _formatearFecha(diagnostico.fechaAnalisis),
            ),
            if (diagnostico.datosDetallados.metadatosImagen.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Metadatos de la Imagen:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              ...diagnostico.datosDetallados.metadatosImagen.entries.map(
                (entry) => _buildDetalleItem(entry.key, entry.value.toString()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$titulo:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrediccionesSection(DiagnosticoDetalle diagnostico) {
    final predicciones = diagnostico.datosDetallados.predicciones;
    final estadisticas = diagnostico.datosDetallados.estadisticas;

    if (predicciones.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Análisis Detallado de IA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Estadísticas
            if (estadisticas.isNotEmpty) ...[
              _buildEstadisticas(estadisticas),
              const SizedBox(height: 16),
            ],

            // Lista de predicciones
            const Text(
              'Predicciones:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...predicciones.map(
              (prediccion) => _buildPrediccionItem(prediccion),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticas(Map<String, dynamic> estadisticas) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas del Modelo:',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: estadisticas.entries.map((entry) {
              return Chip(
                label: Text('${entry.key}: ${entry.value}'),
                backgroundColor: Colors.blue[100],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrediccionItem(PrediccionDetalle prediccion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediccion.clase,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (prediccion.claseId != null)
                    Text(
                      'ID: ${prediccion.claseId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${(prediccion.confianza * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotaImportante() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.orange[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este análisis es asistido por inteligencia artificial y debe ser validado por un médico especialista para un diagnóstico definitivo.',
              style: TextStyle(color: Colors.orange[800], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(DiagnosticoProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error cargando detalle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _cargarDetalle,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Diagnóstico no encontrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'No se pudo cargar la información del diagnóstico',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
