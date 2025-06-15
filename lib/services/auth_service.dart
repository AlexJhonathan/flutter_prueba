import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_model.dart';
import 'package:flutter/material.dart';

class AuthService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api/auth';

  Future<LoginResponse> login(BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(decodedResponse);
        
        // Guardar token, rol y branchId
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', loginResponse.token);
        await prefs.setInt('userRole', loginResponse.role);
        await prefs.setInt('branchId', loginResponse.branchId); // Guardar branchId

        return loginResponse;
      } else {
        final errorBody = json.decode(response.body);
        return LoginResponse(
          token: '', // Proporcionar un valor vacío para el token en caso de error
          role: 0,
          branchId: 0,
          error: errorBody['message'] ?? 'Error al iniciar sesión',
        );
      }
    } catch (e) {
      print('Login error: $e');
      return LoginResponse(
        token: '', // Proporcionar un valor vacío para el token en caso de error
        role: 0,
        branchId: 0,
        error: 'Error de conexión: $e',
      );
    }
  }
}