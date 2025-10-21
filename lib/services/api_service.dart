import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';

class ApiService {
  static final String baseUrl = EnvConfig.apiBaseUrl;
  
  // Sign in
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store token
        await _saveToken(data['access_token']);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Sign in failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: \\$e'};
    }
  }
  
  // Sign up
  static Future<Map<String, dynamic>> signUp(
    String email, 
    String password, 
    String fullName
  ) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Store token if provided
        if (data['access_token'] != null) {
          await _saveToken(data['access_token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Sign up failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: \\$e'};
    }
  }
  
  // Save token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Remove token (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}