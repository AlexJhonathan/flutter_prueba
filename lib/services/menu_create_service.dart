import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_create_model.dart';

class MenuCreateService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';
  
  // Método para obtener el token almacenado en SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> createMenu(MenuCreate menu) async {
    // Obtener el token antes de hacer la solicitud
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final jsonBody = json.encode(menu.toJson());
    print('Request body: $jsonBody'); // Debug what's being sent
    
    final response = await http.post(
      Uri.parse('$baseUrl/menu/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Añadir el token en el encabezado
      },
      body: jsonBody,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to create menu: ${response.body}');
    }
  }
  
  // Nuevo método para actualizar un menú existente
  Future<void> updateMenu(int menuId, String name, int branchId, int status) async {
    // Obtener el token antes de hacer la solicitud
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final jsonBody = json.encode({
      'name': name,
      'branchId': branchId,
      'status': status,
    });
    
    print('Update request body: $jsonBody');
    
    final response = await http.put(
      Uri.parse('$baseUrl/menu/$menuId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonBody,
    );

    print('Update response status: ${response.statusCode}');
    print('Update response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update menu: ${response.body}');
    }
  }
  
  // Método para guardar el token (si es necesario en este servicio)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}