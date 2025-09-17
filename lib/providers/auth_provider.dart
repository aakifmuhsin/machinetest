import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  String? _error;

  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get error => _error;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null && _token!.isNotEmpty) {
      ApiService.setToken(_token!);
    }
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
    ApiService.setToken(token);
  }

  Future<bool> verifyOtp({
    required String countryCode,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.verifyOtp(
        countryCode: countryCode,
        phone: phone,
      );
      // Debug logs to inspect API response in console
      print('verifyOtp success=' + response.success.toString() + ' message=' + response.message);
      print('verifyOtp data=' + response.data.toString());

      if (response.success && response.data != null) {
        final dynamic tokenContainer = response.data!['token'] ?? response.data;
        final String? token = tokenContainer['access'] as String?;
        print('parsed access token: ' + token.toString());
        if (token != null) {
          await _saveToken(token);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _error = response.message.isNotEmpty
          ? response.message
          : 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    ApiService.setToken('');
    notifyListeners();
  }

  bool get isAuthenticated => _token != null;
}

