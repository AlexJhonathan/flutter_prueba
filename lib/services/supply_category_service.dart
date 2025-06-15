import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SupplyCategoryService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Mantener los métodos existentes pero asegurarnos de que tengan los nombres correctos
  
  // Método para registrar un insumo
  Future<void> registrarInsumo(String nombre, String unidad, String categoria) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final url = Uri.parse('$baseUrl/supplies');
    final body = json.encode({
      'name': nombre,
      'unit': unidad,
      'category': categoria,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Operación exitosa
        return;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Error al registrar el insumo: ${errorBody['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error al registrar el insumo: $e');
    }
  }

  // Método para obtener categorías
  Future<List<String>> obtenerCategorias() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final url = Uri.parse('$baseUrl/supply/type');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Extraer categorías únicas
          final tempCategorias = <String>{};
          for (var item in data['data']) {
            if (item['category'] != null) {
              tempCategorias.add(item['category']);
            }
          }
          return tempCategorias.toList()..sort();
        } else {
          throw Exception('No se pudieron obtener las categorías');
        }
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar categorías: $e');
    }
  }

  // Método para obtener insumos por categoría
  Future<List<Map<String, dynamic>>> obtenerInsumosPorCategoria(String categoria) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final url = Uri.parse(
      '$baseUrl/supply/type?category=${Uri.encodeComponent(categoria)}',
    );
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('No se pudieron obtener los insumos');
        }
      } else {
        throw Exception('Error al cargar insumos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar insumos: $e');
    }
  }

  // Método para eliminar un insumo
  Future<void> eliminarInsumo(int id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final url = Uri.parse('$baseUrl/supply/type/$id');
    
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Operación exitosa
        return;
      } else {
        throw Exception('Error al eliminar el insumo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar el insumo: $e');
    }
  }
}