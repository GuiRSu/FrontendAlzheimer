import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/auth_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;
  String _userRole = '';
  String _userName = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  String get userName => _userName;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userRole = prefs.getString('userRole') ?? '';
      _userName = prefs.getString('userName') ?? '';
      notifyListeners();
    } catch (e) {
      print('Error loading auth status: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('/api/auth/login', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        final user = await _getCurrentUser(authResponse.accessToken);

        await _saveAuthData(authResponse.accessToken, user);
        return true;
      } else {
        final error = json.decode(response.body);
        _errorMessage = error['detail'] ?? 'Error en el login';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserResponse> _getCurrentUser(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);

    final response = await ApiService.get('/api/auth/me');

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error obteniendo usuario actual');
    }
  }

  Future<void> _saveAuthData(String token, UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userRole', _mapUserType(user.tipoUsuario));
    await prefs.setString('userName', user.nombre ?? user.username);
    await prefs.setString('authToken', token);

    _isLoggedIn = true;
    _userRole = _mapUserType(user.tipoUsuario);
    _userName = user.nombre ?? user.username;
  }

  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/api/auth/register',
        request.toJson(),
      );

      if (response.statusCode == 201) {
        // Login automático después del registro
        return await login(request.username, request.password);
      } else {
        final error = json.decode(response.body);
        _errorMessage = error['detail'] ?? 'Error en el registro';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapUserType(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'paciente':
        return 'Paciente';
      case 'medico':
        return 'Doctor';
      case 'admin':
        return 'Admin';
      case 'cuidador':
        return 'Cuidador';
      default:
        return 'Paciente';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isLoggedIn = false;
    _userRole = '';
    _userName = '';
    _errorMessage = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
