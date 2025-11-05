import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            title: 'AlzheimerCare',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoading) {
                  return Scaffold(
                    backgroundColor:
                        themeProvider.currentTheme.scaffoldBackgroundColor,
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return authProvider.isLoggedIn
                    ? _buildDashboardByRole(authProvider.userRole)
                    : Login();
              },
            ),
          );
        },
      ),
    );
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
