import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/custom_drawer.dart';
import 'subir_imagen.dart';
import '../../data/providers/auth_provider.dart';

class DashboardPaciente extends StatelessWidget {
  const DashboardPaciente({super.key});

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

            // Próximas citas
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text("Dr. García"),
                subtitle: Text("2024-01-15 10:00"),
                trailing: Chip(label: Text("Programada")),
              ),
            ),
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
}
