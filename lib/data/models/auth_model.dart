class AuthResponse {
  final String accessToken;
  final String tokenType;

  AuthResponse({required this.accessToken, required this.tokenType});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class UserResponse {
  final int id;
  final String username;
  final String tipoUsuario;
  final String? fotoPerfilUrl;
  final bool estado;
  final DateTime createdAt;
  final String? nombre;
  final String? apellido;
  final String? email;
  final String? telefono;

  UserResponse({
    required this.id,
    required this.username,
    required this.tipoUsuario,
    this.fotoPerfilUrl,
    required this.estado,
    required this.createdAt,
    this.nombre,
    this.apellido,
    this.email,
    this.telefono,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      username: json['username'],
      tipoUsuario: json['tipo_usuario'],
      fotoPerfilUrl: json['foto_perfil_url'],
      estado: json['estado'],
      createdAt: DateTime.parse(json['created_at']),
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      telefono: json['telefono'],
    );
  }
}

class RegisterRequest {
  final String username;
  final String password;
  final String tipoUsuario;
  final String nombre;
  final String apellido;
  final String? email;
  final String? telefono;
  final String? fechaNacimiento;
  final String? genero;
  final String? numeroIdentidad;
  final String? direccion;
  final String? ciudad;
  final String? estadoAlzheimer;
  final String? relacionPaciente;
  final String? cmp;
  final String? especialidad;
  final String? hospitalAfiliacion;
  final String? nivelAcceso;
  final String? permisos;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.tipoUsuario,
    required this.nombre,
    required this.apellido,
    this.email,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    this.numeroIdentidad,
    this.direccion,
    this.ciudad,
    this.estadoAlzheimer,
    this.relacionPaciente,
    this.cmp,
    this.especialidad,
    this.hospitalAfiliacion,
    this.nivelAcceso,
    this.permisos,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'username': username,
      'password': password,
      'tipo_usuario': tipoUsuario,
      'nombre': nombre,
      'apellido': apellido,
    };

    //  campos opcionales solo si no son null
    if (email != null) map['email'] = email!;
    if (telefono != null) map['telefono'] = telefono!;
    if (fechaNacimiento != null) map['fecha_nacimiento'] = fechaNacimiento!;
    if (genero != null) map['genero'] = genero!;
    if (numeroIdentidad != null) map['numero_identidad'] = numeroIdentidad!;
    if (direccion != null) map['direccion'] = direccion!;
    if (ciudad != null) map['ciudad'] = ciudad!;
    if (estadoAlzheimer != null) map['estado_alzheimer'] = estadoAlzheimer!;
    if (relacionPaciente != null) map['relacion_paciente'] = relacionPaciente!;
    if (cmp != null) map['cmp'] = cmp!;
    if (especialidad != null) map['especialidad'] = especialidad!;
    if (hospitalAfiliacion != null)
      map['hospital_afiliacion'] = hospitalAfiliacion!;
    if (nivelAcceso != null) map['nivel_acceso'] = nivelAcceso!;
    if (permisos != null) map['permisos'] = permisos!;

    return map;
  }
}
