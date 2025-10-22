import 'dart:convert';
//import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../models/user_response.dart';

class AuthRepository {
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await ApiService.post('/api/auth/login', request.toJson());

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Error en el login');
    }
  }

  Future<UserResponse> register(RegisterRequest request) async {
    final response = await ApiService.post(
      '/api/auth/register',
      request.toJson(),
    );

    if (response.statusCode == 201) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Error en el registro');
    }
  }

  Future<UserResponse> getCurrentUser(String token) async {
    final response = await ApiService.get('/api/auth/me', token);

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error obteniendo usuario actual');
    }
  }
}
