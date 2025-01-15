import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_model.dart';
import 'package:flutter/material.dart';

class AuthService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<LoginResponse> login(BuildContext context, String email, String password) async {
    try {
      // Primera llamada - login
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response: ${loginResponse.body}'); // Para debugging

      if (loginResponse.statusCode == 200) {
        final loginData = json.decode(loginResponse.body);
        final token = loginData['token'];

        // Segunda llamada - obtener datos del usuario
        final userResponse = await http.get(
          Uri.parse('$baseUrl/user'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print('User response: ${userResponse.body}'); // Para debugging

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          
          // Convertir el rol a int de manera segura
          int role;
          if (userData['role'] is String) {
            role = int.tryParse(userData['role']) ?? 0;
          } else if (userData['role'] is int) {
            role = userData['role'];
          } else {
            role = 0;
          }

          final LoginResponse response = LoginResponse(
            token: token,
            role: role,
            error: '',
          );

          // Guardar token y rol
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', response.token);
          await prefs.setInt('userRole', response.role);

          return response;
        } else {
          return LoginResponse(error: 'Error al obtener datos del usuario');
        }
      } else {
        final errorBody = json.decode(loginResponse.body);
        return LoginResponse(
          error: errorBody['message'] ?? 'Error al iniciar sesión'
        );
      }
    } catch (e) {
      print('Login error: $e'); // Para debugging
      return LoginResponse(error: 'Error de conexión: $e');
    }
  }
}