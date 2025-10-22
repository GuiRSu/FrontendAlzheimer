import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/custom_drawer.dart';
import '../../providers/auth_provider.dart';

class DashboardDoctor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Panel Médico"),
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
              authProvider.userName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text("Panel médico"),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _infoCard(Icons.people, "24", "Pacientes")),
                SizedBox(width: 10),
                Expanded(
                  child: _infoCard(Icons.calendar_today, "6", "Citas hoy"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.error, color: Colors.red),
                title: Text("Diagnósticos Pendientes"),
                subtitle: Text("Juan Pérez - Confianza 72%"),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text("Revisar"),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text("Ver todos los pendientes"),
            ),
            SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Citas de Hoy")),
                  ListTile(
                    title: Text("María González"),
                    subtitle: Text("10:00"),
                    trailing: Icon(Icons.call),
                  ),
                  ListTile(
                    title: Text("Juan Pérez"),
                    subtitle: Text("14:30"),
                    trailing: Icon(Icons.call),
                  ),
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
}
