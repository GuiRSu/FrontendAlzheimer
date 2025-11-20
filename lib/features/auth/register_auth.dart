import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/auth_model.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  final _fechaNacimientoController = TextEditingController();
  final _generoController = TextEditingController();
  final _numeroIdentidadController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _cmpController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _hospitalController = TextEditingController();

  String _selectedTipoUsuario = "paciente";
  String? _selectedGenero;
  String? _selectedEstadoAlzheimer;
  String? _selectedNivelAcceso;

  bool _isLoading = false;

  // Listas para dropdowns
  final List<String> _tiposUsuario = [
    "paciente",
    "medico",
    "admin",
  ];
  final List<String> _generos = ["Masculino", "Femenino", "Otro"];
  final List<String> _estadosAlzheimer = ["independiente", "dependiente"];
  final List<String> _nivelesAcceso = ["total", "limitado"];

  Widget _buildTipoUsuarioField() {
    return DropdownButtonFormField<String>(
      value: _selectedTipoUsuario,
      items: _tiposUsuario
          .map((e) => DropdownMenuItem(value: e, child: Text(_capitalize(e))))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedTipoUsuario = value!;
        });
      },
      decoration: InputDecoration(
        labelText: "Tipo de usuario",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona un tipo de usuario';
        }
        return null;
      },
    );
  }

  Widget _buildCamposEspecificos() {
    switch (_selectedTipoUsuario) {
      case "paciente":
        return Column(
          children: [
            TextFormField(
              controller: _fechaNacimientoController,
              decoration: InputDecoration(
                labelText: "Fecha de Nacimiento (YYYY-MM-DD)",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La fecha de nacimiento es obligatoria para pacientes';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGenero,
              items: _generos
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGenero = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Género",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _numeroIdentidadController,
              decoration: InputDecoration(
                labelText: "Número de Identidad",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: "Dirección",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _ciudadController,
              decoration: InputDecoration(
                labelText: "Ciudad",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEstadoAlzheimer,
              items: _estadosAlzheimer
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(_capitalize(e.replaceAll('_', ' '))),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEstadoAlzheimer = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Estado Alzheimer",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );

      case "medico":
        return Column(
          children: [
            TextFormField(
              controller: _cmpController,
              decoration: InputDecoration(
                labelText: "CMP (Número de Colegiatura)",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El CMP es obligatorio para médicos';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _especialidadController,
              decoration: InputDecoration(
                labelText: "Especialidad",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _hospitalController,
              decoration: InputDecoration(
                labelText: "Hospital de Afiliación",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _numeroIdentidadController,
              decoration: InputDecoration(
                labelText: "Número de Identidad",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );

      case "admin":
        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedNivelAcceso,
              items: _nivelesAcceso
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(_capitalize(e))),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNivelAcceso = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Nivel de Acceso",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );

      default:
        return SizedBox.shrink();
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Las contraseñas no coinciden')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final request = RegisterRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        tipoUsuario: _selectedTipoUsuario,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        fechaNacimiento: _fechaNacimientoController.text.trim().isEmpty
            ? null
            : _fechaNacimientoController.text.trim(),
        genero: _selectedGenero,
        numeroIdentidad: _numeroIdentidadController.text.trim().isEmpty
            ? null
            : _numeroIdentidadController.text.trim(),
        direccion: _direccionController.text.trim().isEmpty
            ? null
            : _direccionController.text.trim(),
        ciudad: _ciudadController.text.trim().isEmpty
            ? null
            : _ciudadController.text.trim(),
        estadoAlzheimer: _selectedEstadoAlzheimer,
        cmp: _cmpController.text.trim().isEmpty
            ? null
            : _cmpController.text.trim(),
        especialidad: _especialidadController.text.trim().isEmpty
            ? null
            : _especialidadController.text.trim(),
        hospitalAfiliacion: _hospitalController.text.trim().isEmpty
            ? null
            : _hospitalController.text.trim(),
        nivelAcceso: _selectedNivelAcceso,
        permisos: _selectedNivelAcceso == "total" ? "all" : "basic",
      );

      final success = await authProvider.register(request);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registro exitoso!')));
        // La navegación se maneja automáticamente en el AuthProvider
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crear Cuenta"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
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

              // Campos basicos
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Usuario*",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El usuario es obligatorio';
                  }
                  if (value.length < 3) {
                    return 'El usuario debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre*",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(
                  labelText: "Apellido*",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El apellido es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Ingresa un email válido (ej: usuario@dominio.com)';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(
                  labelText: "Teléfono",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña*",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirmar Contraseña*",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Tipo de usuario
              _buildTipoUsuarioField(),
              SizedBox(height: 20),

              // Campos específicos según tipo de usuario
              Text(
                "Información Específica",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildCamposEspecificos(),
              SizedBox(height: 30),

              // Botón de registro
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _handleRegister(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        "Crear Cuenta",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Ya tengo una cuenta"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    _generoController.dispose();
    _numeroIdentidadController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _cmpController.dispose();
    _especialidadController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }
}
