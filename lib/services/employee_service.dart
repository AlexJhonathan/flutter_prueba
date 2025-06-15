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
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<EmployeeResponse> addEmployee(String name, String email, String password, int role, int branchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) throw Exception('Token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/user/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'branchId': branchId, // Asegurarse de usar 'branchId'
        }),
      );

      print('Request URL: $baseUrl/employee/');
      print('Request headers: ${{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }}');
      print('Request body: ${json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'branchId': branchId, // Asegurarse de usar 'branchId'
      })}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return EmployeeResponse.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        return EmployeeResponse(error: errorBody['message'] ?? 'Failed to add employee');
      }
    } catch (e) {
      return EmployeeResponse(error: e.toString());
    }
  }
}