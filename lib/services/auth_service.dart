import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3001/api/auth';
  static const String _tokenKey = 'auth_token';

  AppUser? _currentUser;
  String? _token;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;

  /// Sign in with email and password
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = AppUser.fromJson(data['user']);

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);

        return _currentUser;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  /// Register new user
  Future<AppUser?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = AppUser.fromJson(data['user']);

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);

        return _currentUser;
      }
    } catch (e) {
      print('Register error: $e');
    }
    return null;
  }

  /// Get current user info
  Future<AppUser?> getMe() async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = AppUser.fromJson(data);
        return _currentUser;
      }
    } catch (e) {
      print('Get me error: $e');
    }
    return null;
  }

  /// Load token and user from shared preferences
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    if (_token != null) {
      // Try to get user info with the token
      await getMe();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _token = null;

    // Remove token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
