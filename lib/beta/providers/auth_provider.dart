import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> login(String email, String password) async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 1));
    _user = User(email: email);
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 1));
    _user = User(email: email);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}
