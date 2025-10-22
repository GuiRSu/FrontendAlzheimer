import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../models/user_response.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  UserResponse? _currentUser;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  UserResponse? get currentUser => _currentUser;

  // Mapeo de tipos de usuario del backend a Flutter
  /*
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
*/
  String _token = '';

  String get token => _token;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final request = LoginRequest(username: username, password: password);
      final AuthResponse authResponse = await _authRepository.login(request);

      // guardar token
      _token = authResponse.accessToken;

      // infor del usuario
      _currentUser = await _authRepository.getCurrentUser(_token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
