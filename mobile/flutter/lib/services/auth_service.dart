// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}${Constants.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['token']);
      return true;
    }
    return false;
  }

  static Future<bool> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}${Constants.registerEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return null;
    // Aquí se puede añadir lógica para obtener datos del usuario con el token
    return null;
  }
}
