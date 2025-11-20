import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/custom_drawer.dart';
import 'subir_imagen.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/citas_provider.dart';
import '../../data/models/cita_model.dart';
import '../citas/gestion_citas.dart';
import '../citas/formulario_cita.dart';
import '../citas/detalle_cita.dart';

class DashboardPaciente extends StatefulWidget {
  const DashboardPaciente({super.key});

  @override
  State<DashboardPaciente> createState() => _DashboardPacienteState();
}

class _DashboardPacienteState extends State<DashboardPaciente> {
  @override
  void initState() {
    super.initState();
    _cargarProximasCitas();
  }

  void _cargarProximasCitas() {
    final hoy = DateTime.now();
    final fechaDesde =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    Future.microtask(() {
      final citasProvider =
          Provider.of<CitasProvider>(context, listen: false);
      citasProvider.cargarCitas(
        estado: 'programada',
        fechaDesde: fechaDesde,
        limit: 3, // Solo las próximas 3 citas
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Panel Paciente"),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      drawer: MainDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Hola, ${authProvider.userName}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text("Bienvenido a tu panel de control"),
            SizedBox(height: 20),

            // Sección de Próximas Citas
            _buildProximasCitasCard(context),
            SizedBox(height: 20),

            // Botón Subir Imagen
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science_outlined, color: Colors.black54),
                        SizedBox(width: 8),
                        Text(
                          "Nuevo Diagnóstico",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("Sube una imagen médica para análisis"),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SubirImagen()),
                        );
                      },
                      icon: Icon(Icons.upload_file),
                      label: Text("Subir Imagen"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProximasCitasCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Mis Próximas Citas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _cargarProximasCitas,
                  tooltip: 'Actualizar',
                ),
              ],
            ),
            SizedBox(height: 10),

            // Lista de citas
            Consumer<CitasProvider>(
              builder: (context, citasProvider, child) {
                if (citasProvider.isLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (citasProvider.citas.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(height: 8),
                      Text(
                        "No tienes citas programadas",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FormularioCita(),
                            ),
                          );
                          if (resultado == true) {
                            _cargarProximasCitas();
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text("Agendar Nueva Cita"),
                      ),
                    ],
                  );
                }

                  return Column(
                  children: [
                    // Mostrar hasta 3 citas
                    ...citasProvider.citas.take(3).map((cita) {
                      return _buildCitaListTile(context, cita);
                    }),
                    SizedBox(height: 12),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final resultado = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FormularioCita(),
                                ),
                              );
                              if (resultado == true) {
                                _cargarProximasCitas();
                              }
                            },
                            icon: Icon(Icons.add),
                            label: Text("Nueva Cita"),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GestionCitas(),
                                ),
                              );
                            },
                            icon: Icon(Icons.list),
                            label: Text("Ver Todas"),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitaListTile(BuildContext context, CitaModel cita) {
    Color estadoColor;
    switch (cita.estado) {
      case 'programada':
        estadoColor = Colors.blue;
        break;
      case 'completada':
        estadoColor = Colors.green;
        break;
      case 'cancelada':
        estadoColor = Colors.red;
        break;
      case 'reprogramada':
        estadoColor = Colors.orange;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: estadoColor.withAlpha(51),
          child: Icon(Icons.local_hospital, color: estadoColor),
        ),
        title: Text(
          'Dr. ${cita.medicoNombreCompleto}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              DateFormat('EEEE, dd MMM yyyy', 'es').format(cita.fechaHora),
            ),
            Text(
              DateFormat('HH:mm', 'es').format(cita.fechaHora),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            cita.estadoFormatted,
            style: TextStyle(fontSize: 11),
          ),
          backgroundColor: estadoColor.withAlpha(51),
        ),
        onTap: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleCita(citaId: cita.id),
            ),
          );
          if (resultado == true) {
            _cargarProximasCitas();
          }
        },
      ),
    );
  }
}
