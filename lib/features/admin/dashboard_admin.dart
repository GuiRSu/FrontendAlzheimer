import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/custom_drawer.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/admin_provider.dart';
import 'historial_completo.dart';
import 'estadisticas_detalladas.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.cargarDashboardCompleto();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administración"),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar datos',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EstadisticasDetalladas(),
                ),
              );
            },
            tooltip: 'Estadísticas detalladas',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistorialCompletoAdmin(),
                ),
              );
            },
            tooltip: 'Historial completo',
          ),
        ],
      ),
      drawer: MainDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: adminProvider.isLoading && adminProvider.dashboardCompleto == null
            ? const Center(child: CircularProgressIndicator())
            : adminProvider.errorMessage.isNotEmpty
                ? _buildError(adminProvider.errorMessage)
                : _buildDashboardContent(adminProvider, colorScheme),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error al cargar datos',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargarDatos,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(AdminProvider provider, ColorScheme colorScheme) {
    final stats = provider.estadisticasGenerales;

    if (stats == null) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [

        // Tarjetas de estadísticas principales
        _buildStatsCards(stats, colorScheme),
        const SizedBox(height: 20),

        // Diagnósticos por clasificación
        _buildDiagnosticosSection(provider, colorScheme),
        const SizedBox(height: 20),

        // Citas por hospital
        _buildCitasHospitalSection(provider, colorScheme),
        const SizedBox(height: 20),

        // Actividad reciente
        _buildActividadRecienteSection(provider, colorScheme),
        const SizedBox(height: 20),

        // Pacientes destacados
        _buildPacientesDestacadosSection(provider, colorScheme),
        const SizedBox(height: 20),

        // Médicos destacados
        _buildMedicosSection(provider, colorScheme),
      ],
    );
  }

  Widget _buildStatsCards(stats, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _infoCard(
                Icons.people,
                stats.totalUsuarios.toString(),
                "Usuarios Total",
                colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoCard(
                Icons.memory,
                stats.totalDiagnosticos.toString(),
                "Diagnósticos",
                colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _infoCard(
                Icons.calendar_today,
                stats.totalCitas.toString(),
                "Citas Total",
                colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoCard(
                Icons.trending_up,
                stats.diagnosticosUltimoMes.toString(),
                "Este Mes",
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Distribución de usuarios
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Distribución de Usuarios",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...stats.usuariosPorTipo.entries.map((entry) {
                  final total = stats.totalUsuarios > 0 ? stats.totalUsuarios : 1;
                  final percentage = (entry.value / total);
                  return _progressRow(
                    _capitalizeTipo(entry.key),
                    percentage,
                    entry.value.toString(),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticosSection(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.diagnosticosPorClasificacion.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Diagnósticos por Clasificación",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.show_chart, color: colorScheme.primary),
              ],
            ),
            const Divider(),
            ...provider.diagnosticosPorClasificacion.take(5).map((diag) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColorForClasificacion(diag.clasificacion ?? ''),
                  child: Text(
                    (diag.cantidad ?? 0).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(diag.clasificacion ?? 'Sin clasificación'),
                subtitle: Text(
                  'Confianza promedio: ${(diag.confianzaPromedio ?? 0).toStringAsFixed(1)}%',
                ),
                trailing: Text(
                  '${diag.pacientesUnicos ?? 0} pacientes',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCitasHospitalSection(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.citasPorHospital.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Citas por Hospital",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.local_hospital, color: colorScheme.primary),
              ],
            ),
            const Divider(),
            ...provider.citasPorHospital.take(3).map((hospital) {
              return ExpansionTile(
                leading: Icon(Icons.business, color: colorScheme.primary),
                title: Text(hospital.hospital ?? 'Sin hospital'),
                subtitle: Text('${hospital.ciudad ?? 'N/A'} - Total: ${hospital.totalCitas ?? 0}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _miniStat('Programadas', hospital.programadas ?? 0, Colors.blue),
                        _miniStat('Completadas', hospital.completadas ?? 0, Colors.green),
                        _miniStat('Canceladas', hospital.canceladas ?? 0, Colors.red),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActividadRecienteSection(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.actividadReciente.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Actividad Reciente",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.timeline, color: colorScheme.primary),
              ],
            ),
            const Divider(),
            ...provider.actividadReciente.take(5).map((actividad) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColorForActividad(actividad.tipo ?? ''),
                  child: Icon(
                    _getIconForActividad(actividad.tipo ?? ''),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(actividad.descripcion ?? 'Sin descripción'),
                subtitle: Text(_formatearFecha(actividad.fecha ?? DateTime.now())),
                dense: true,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPacientesDestacadosSection(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.pacientesDestacados.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pacientes Activos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.person, color: colorScheme.primary),
              ],
            ),
            const Divider(),
            ...provider.pacientesDestacados.take(5).map((paciente) {
              final nombre = paciente.nombre ?? 'N/A';
              final apellido = paciente.apellido ?? '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                title: Text('$nombre $apellido'),
                subtitle: Text(
                  'Edad: ${paciente.edad ?? 0} | ${paciente.estadoAlzheimer ?? 'N/A'}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${paciente.totalDiagnosticos ?? 0} dx',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${paciente.totalCitas ?? 0} citas',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicosSection(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.medicosEstadisticas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Médicos Activos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.medical_services, color: colorScheme.primary),
              ],
            ),
            const Divider(),
            ...provider.medicosEstadisticas.take(5).map((medico) {
              final nombre = medico.nombre ?? 'N/A';
              final apellido = medico.apellido ?? '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'M',
                    style: TextStyle(color: colorScheme.secondary),
                  ),
                ),
                title: Text('Dr. $nombre $apellido'),
                subtitle: Text(medico.especialidad ?? 'Sin especialidad'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${medico.pacientesAsignados ?? 0} pac.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${medico.citasProgramadas ?? 0} citas',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressRow(String label, double value, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                count,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              value > 0.7 ? Colors.green : value > 0.4 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _capitalizeTipo(String tipo) {
    if (tipo.isEmpty) return tipo;
    return tipo[0].toUpperCase() + tipo.substring(1);
  }

  Color _getColorForClasificacion(String clasificacion) {
    final lower = clasificacion.toLowerCase();
    if (lower.contains('sin demencia') || lower.contains('non')) return Colors.green;
    if (lower.contains('leve') || lower.contains('mild')) return Colors.orange;
    if (lower.contains('moderada') || lower.contains('moderate')) return Colors.red;
    return Colors.blue;
  }

  Color _getColorForActividad(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'diagnostico':
        return Colors.blue;
      case 'cita':
        return Colors.green;
      case 'usuario':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForActividad(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'diagnostico':
        return Icons.analytics;
      case 'cita':
        return Icons.event;
      case 'usuario':
        return Icons.person_add;
      default:
        return Icons.circle;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) return 'Justo ahora';
    if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inDays < 1) return 'Hace ${diferencia.inHours} horas';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';

    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }
}
