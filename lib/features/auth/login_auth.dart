import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../paciente/dashboard_paciente.dart';
import '../doctor/dashboard_doctor.dart';
import '../admin/dashboard_admin.dart';
import 'register_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      _navigateToDashboard(context, authProvider.userRole);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage)));
    }
  }

  void _navigateToDashboard(BuildContext context, String role) {
    Widget destination;
    switch (role) {
      case 'Paciente':
        destination = DashboardPaciente();
        break;
      case 'Doctor':
        destination = DashboardDoctor();
        break;
      case 'Admin':
        destination = DashboardAdmin();
        break;
      default:
        destination = DashboardPaciente();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(Icons.memory, size: 80, color: Colors.blue),
                SizedBox(height: 20),
                Text(
                  "Iniciar Sesión",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text("Accede a tu cuenta de AlzheimerCare"),
                SizedBox(height: 20),

                if (authProvider.errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      authProvider.errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // ✅ CORREGIDO: Usar isLoading en lugar de authLoading
                if (authProvider.isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () => _handleLogin(context),
                    child: Text("Iniciar Sesión"),
                  ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Register()),
                    );
                  },
                  child: Text("Crear cuenta nueva"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
