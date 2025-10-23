import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'views/auth/login_auth.dart';
import 'views/paciente/dashboard_paciente.dart';
import 'views/doctor/dashboard_doctor.dart';
import 'views/admin/dashboard_admin.dart';
import 'viewmodels/diagnostico_viewmodel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DiagnosticoViewModel()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "AlzheimerCare",
            theme: ThemeData.light(),
            home: authProvider.isLoggedIn
                ? _getDashboardByRole(authProvider.userRole)
                : Login(),
          );
        },
      ),
    );
  }

  Widget _getDashboardByRole(String role) {
    switch (role) {
      case 'Paciente':
        return DashboardPaciente();
      case 'Doctor':
        return DashboardDoctor();
      case 'Admin':
        return DashboardAdmin();
      case 'Cuidador':
        return DashboardPaciente(); // Temporal - falta dashboard para cuidador (?)
      default:
        return Login();
    }
  }
}
