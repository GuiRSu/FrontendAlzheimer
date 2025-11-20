import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../features/admin/historial_completo.dart';
import '../../features/auth/login_auth.dart';
import '../../features/citas/gestion_citas.dart';
import '../../features/paciente/historial_diagnosticos.dart';
import '../../features/paciente/subir_imagen.dart';
import '../../features/paciente/dashboard_paciente.dart';
import '../../features/doctor/dashboard_doctor.dart';
import '../../features/admin/dashboard_admin.dart';
import 'settings.dart';

class MainDrawer extends StatelessWidget {
  final String currentRole;
  final String currentUserName;

  const MainDrawer({
    super.key,
    required this.currentRole,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 30),
                ),
                SizedBox(height: 10),
                Text(
                  currentUserName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentRole,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Main Menu
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard Principal'),
            onTap: () {
              Navigator.pop(context);
              _navigateToDashboard(context, currentRole);
            },
          ),

          // Diagnósticos
          if (currentRole == 'Paciente') ...[
            _buildDrawerItem(
              icon: Icons.upload_file,
              title: 'Subir Imagen',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SubirImagen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: 'Historial de Diagnósticos',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistorialDiagnosticos()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              title: 'Mis Citas',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GestionCitas()),
                );
              },
            ),
          ],

          // Gestión de pacientes
          if (currentRole == 'Doctor') ...[
            _buildDrawerItem(
              icon: Icons.people,
              title: 'Mis Pacientes',
              onTap: () {
                Navigator.pop(context);
                // Navegar a gestión de pacientes
              },
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              title: 'Agenda',
              onTap: () {
                Navigator.pop(context);
                // Pendiente: Navegar a agenda
              },
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              title: 'Mis Citas',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GestionCitas()),
                );
              },
            ),
          ],

          // Gestión de usuarios
          if (currentRole == 'Admin') ...[
            _buildDrawerItem(
              icon: Icons.supervised_user_circle,
              title: 'Gestión de Usuarios',
              onTap: () {
                Navigator.pop(context);
                // Pendiente: Navegar a gestión de usuarios
              },
            ),
            _buildDrawerItem(
              icon: Icons.analytics,
              title: 'Estadísticas',
              onTap: () {
                Navigator.pop(context);
                // Pendiente: Navegar a estadísticas
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: 'Historial Completo',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistorialCompletoAdmin()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.assignment,
              title: 'Gestión de Citas',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GestionCitas()),
                );
              },
            ),
          ],

          // Settings
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Configuración',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Settings()),
              );
            },
          ),

          Divider(),

          // Cerrar sesión
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context, authProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  void _navigateToDashboard(BuildContext context, String role) {
    switch (role) {
      case 'Paciente':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardPaciente()),
          (route) => false,
        );
        break;
      case 'Doctor':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardDoctor()),
          (route) => false,
        );
        break;
      case 'Admin':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardAdmin()),
          (route) => false,
        );
        break;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => Login()),
                  (route) => false,
                );
              },
              child: Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
