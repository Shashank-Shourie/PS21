import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  final ApiService api;
  final SharedPreferences prefs;

  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;

  AuthService({required this.api, required this.prefs}) {
    _checkAuth();
  }

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get role => _user?['role'];

  Future<void> _checkAuth() async {
    final token = prefs.getString('token');
    if (token != null) {
      _isAuthenticated = true;
      // You might want to verify token with backend here
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _user = await api.login(email, password);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await prefs.remove('token');
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}