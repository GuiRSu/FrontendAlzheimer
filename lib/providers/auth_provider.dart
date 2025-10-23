import 'package:flutter/material.dart';
import 'package:frontendalzheimer/models/user_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/register_request.dart';

class AuthProvider with ChangeNotifier {
  final AuthViewModel _authViewModel = AuthViewModel();

  bool _isLoggedIn = false;
  String _userRole = '';
  String _userName = '';
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  String get userName => _userName;
  bool get isLoading => _isLoading;
  bool get authLoading => _authViewModel.isLoading;
  String get errorMessage => _authViewModel.errorMessage;

  static const String _authKey = 'isLoggedIn';
  static const String _roleKey = 'userRole';
  static const String _nameKey = 'userName';
  static const String _tokenKey = 'authToken';

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_authKey) ?? false;
      _userRole = prefs.getString(_roleKey) ?? '';
      _userName = prefs.getString(_nameKey) ?? '';
    } catch (e) {
      print('Error loading auth status: $e');
      _isLoggedIn = false;
      _userRole = '';
      _userName = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    final success = await _authViewModel.login(username, password);

    if (success && _authViewModel.currentUser != null) {
      await _saveAuthData(_authViewModel.token!, _authViewModel.currentUser!);

      _isLoggedIn = true;
      _userRole = _mapUserType(_authViewModel.currentUser!.tipoUsuario);
      _userName =
          _authViewModel.currentUser!.nombre ??
          _authViewModel.currentUser!.username;

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _saveAuthData(String token, UserResponse user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      await prefs.setString(_roleKey, _mapUserType(user.tipoUsuario));
      await prefs.setString(_nameKey, user.nombre ?? user.username);
      await prefs.setString(_tokenKey, token); // GUARDAR TOKEN

      print('Token guardado: ${token.substring(0, 20)}...'); // Debug
    } catch (e) {
      print('Error guardando auth data: $e');
      throw e;
    }
  }

  Future<String> get debugToken {
    final prefs = SharedPreferences.getInstance();
    return prefs.then((prefs) => prefs.getString(_tokenKey) ?? 'No token');
  }

  Future<bool> register(RegisterRequest request) async {
    final success = await _authViewModel.register(request);

    if (success && _authViewModel.currentUser != null) {
      return await login(request.username, request.password);
    }
    return false;
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, false);
      await prefs.remove(_roleKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_tokenKey);

      _isLoggedIn = false;
      _userRole = '';
      _userName = '';
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      throw e;
    }
  }

  void clearError() {
    _authViewModel.clearError();
  }
}
