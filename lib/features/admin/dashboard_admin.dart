import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/custom_drawer.dart';
import '../../data/providers/auth_provider.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Panel de Admin"),
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
            Row(
              children: [
                Expanded(
                  child: _infoCard(Icons.people, "156", "Usuarios Total"),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _infoCard(Icons.memory, "89", "Diagnósticos Hoy"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Estadísticas de Uso",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _progressRow("Pacientes Activos", 0.78),
                    _progressRow("Médicos Online", 0.92),
                    _progressRow("Precisión IA", 0.95),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Gestión de Usuarios")),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add),
                    label: Text("Agregar Usuario"),
                  ),
                  ListTile(title: Text("Pacientes (124)")),
                  ListTile(title: Text("Médicos (28)")),
                  ListTile(title: Text("Administradores (4)")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _progressRow(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        LinearProgressIndicator(value: value),
        SizedBox(height: 10),
      ],
    );
  }
}
