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
