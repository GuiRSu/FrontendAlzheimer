import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(AlzheimerCareApp());
}

class AlzheimerCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AlzheimerCare",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

/// ---------------- LOGIN ----------------
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = "Paciente";

  @override
  Widget build(BuildContext context) {
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
                TextField(
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ["Paciente", "Doctor", "Admin"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Tipo de usuario",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (selectedRole == "Paciente") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardPaciente()),
                      );
                    } else if (selectedRole == "Doctor") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardDoctor()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardAdmin()),
                      );
                    }
                  },
                  child: Text("Iniciar Sesión"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
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

/// ---------------- REGISTRO ----------------
class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  "Crear Cuenta",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text("Únete a AlzheimerCare"),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Nombre completo",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  items: ["Paciente", "Doctor", "Admin"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    labelText: "Tipo de usuario",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Crear Cuenta"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ya tengo cuenta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- DASHBOARD PACIENTE ----------------
class DashboardPaciente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panel Paciente"),
        actions: [Icon(Icons.notifications_none)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Hola, María González",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text("Bienvenido a tu panel de control"),
            SizedBox(height: 20),

            // Próximas citas (simplificado)
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
                          MaterialPageRoute(
                            builder: (_) => PantallaSubirImagen(),
                          ),
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

/// ---------------- SUBIR IMAGEN MÉDICA ----------------
class PantallaSubirImagen extends StatefulWidget {
  @override
  _PantallaSubirImagenState createState() => _PantallaSubirImagenState();
}

class _PantallaSubirImagenState extends State<PantallaSubirImagen> {
  File? _imagen;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagen = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subir Imagen Médica")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _imagen == null
                        ? Column(
                            children: [
                              Icon(Icons.image, size: 120, color: Colors.grey),
                              Text(
                                "Selecciona una imagen MRI o CT scan para análisis",
                              ),
                            ],
                          )
                        : Image.file(_imagen!, height: 200),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo),
                      label: Text("Galería"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text("Cámara"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _imagen != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PantallaResultadoDiagnostico(
                                    imagen: _imagen!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text("Analizar"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recomendaciones",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• Asegúrate de que la imagen sea clara y de alta resolución",
                    ),
                    Text("• Los formatos compatibles: JPEG, PNG, DICOM"),
                    Text("• El análisis puede tomar 2-5 minutos"),
                    Text("• Los resultados serán validados por un médico"),
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

/// ---------------- RESULTADOS ----------------
class PantallaResultadoDiagnostico extends StatelessWidget {
  final File imagen;

  PantallaResultadoDiagnostico({required this.imagen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resultados del Diagnóstico")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Análisis Completado",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Riesgo Bajo",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Confianza: 85%"),
                    SizedBox(height: 20),
                    _progressRow("Probabilidad de Alzheimer", 0.15),
                    _progressRow("Deterioro Cognitivo Leve", 0.08),
                    _progressRow("Estado Normal", 0.77),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Imagen Analizada")),
                  Image.file(imagen, height: 200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.remove_red_eye),
                        label: Text("Ver Original"),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.analytics),
                        label: Text("Segmentación"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressRow(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label ${(value * 100).toStringAsFixed(0)}%"),
        LinearProgressIndicator(value: value),
        SizedBox(height: 10),
      ],
    );
  }
}

/// ---------------- DASHBOARD DOCTOR ----------------
class DashboardDoctor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panel Médico")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Dr. García",
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

/// ---------------- DASHBOARD ADMIN ----------------
class DashboardAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panel de Admin")),
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
