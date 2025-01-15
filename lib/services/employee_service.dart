import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeResponse {
  final String error;

  EmployeeResponse({this.error = ''});

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      error: json['error'] ?? '',
    );
  }
}

class EmployeeService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo';

  Future<EmployeeResponse> addEmployee(String name, String email, String password, int role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) throw Exception('Token not found');

      final requestBody = {
        "name": name,
        "email": email,
        "password": password,
        "role": role
      };

      print('URL completa: $baseUrl/api/user/');
      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/user/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return EmployeeResponse.fromJson(json.decode(response.body));
      } else {
        try {
          final errorBody = json.decode(response.body);
          return EmployeeResponse(
            error: errorBody['message'] ?? errorBody['error'] ?? 'Error del servidor: ${response.statusCode}'
          );
        } catch (e) {
          return EmployeeResponse(
            error: 'Error del servidor ${response.statusCode}: ${response.body}'
          );
        }
      }
    } catch (e) {
      print('Exception caught: $e');
      return EmployeeResponse(error: 'Error de conexión: ${e.toString()}');
    }
  }
}