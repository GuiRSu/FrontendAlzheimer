import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/widgets/splash_screen.dart';

import 'data/providers/auth_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/diagnostico_provider.dart';

import 'features/auth/login_auth.dart';
import 'features/admin/dashboard_admin.dart';
import 'features/doctor/dashboard_doctor.dart';
import 'features/paciente/dashboard_paciente.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DiagnosticoProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AlzheCare',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            home: SplashWrapper(), // <-- Cambia aquí
          );
        },
      ),
    );
  }
}

// Nuevo widget para manejar el splash y la navegación posterior
class SplashWrapper extends StatefulWidget {
  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(Duration(seconds: 2)); // Simula carga
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return SplashScreen();
    }
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.currentTheme.scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return authProvider.isLoggedIn
        ? _buildDashboardByRole(authProvider.userRole)
        : Login();
  }

  Widget _buildDashboardByRole(String role) {
    switch (role) {
      case 'Paciente':
        return DashboardPaciente();
      case 'Doctor':
        return DashboardDoctor();
      case 'Admin':
        return DashboardAdmin();
      default:
        return DashboardPaciente();
    }
  }
}
// ...existing code...