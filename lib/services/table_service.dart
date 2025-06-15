import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TableService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<List<Map<String, dynamic>>> getTablesByBranch(int branchId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/table/branch/$branchId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al obtener las mesas: ${response.body}');
    }
  }

  Future<void> addTable(int branchId, int number, bool status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/table'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'branchId': branchId,
        'number': number,
        'status': status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al añadir la mesa: ${response.body}');
    }
  }

  Future<void> updateTableStatus(int tableId, bool status) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('No hay token de autenticación');
  }

  final response = await http.patch(  // Changed from PUT to PATCH
    Uri.parse('$baseUrl/table/$tableId/status'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({
      'status': status,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al cambiar el estado de la mesa: ${response.body}');
  }
}

  Future<void> deleteTable(int tableId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/table/$tableId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar la mesa: ${response.body}');
    }
  }
}