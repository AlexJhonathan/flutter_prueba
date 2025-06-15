import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_list_model.dart';

class MenuListService {
  static const String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Menu>> getMenus() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/menu/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Menu.fromJson(json)).toList();
      } else {
        final errorMessage = _parseErrorMessage(response);
        throw Exception('Error al cargar menús: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<MenuProduct>> getMenuProducts(int menuId, String category) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final Uri uri;
      if (category == 'Todas') {
        uri = Uri.parse('$baseUrl/menu/details/category?menuId=$menuId');
      } else {
        uri = Uri.parse('$baseUrl/menu/details/category?menuId=$menuId&category=$category');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<dynamic> jsonList = jsonData['rows'] ?? [];
        return jsonList.map((json) => MenuProduct.fromJson(json)).toList();
      } else {
        final errorMessage = _parseErrorMessage(response);
        throw Exception('Error al cargar productos del menú: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> addMenuProducts(int menuId, List<int> productIds) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Preparar el cuerpo de la solicitud
      final requestBody = {
        'menuId': menuId,
        'details': productIds.map((id) => {'productId': id}).toList(),
      };
      
      print('Enviando solicitud: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/menu/details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      // Considerar cualquier código 2xx como éxito
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return; // Operación exitosa
      } else {
        final errorMessage = _parseErrorMessage(response);
        throw Exception('Error al añadir productos al menú: $errorMessage');
      }
    } catch (e) {
      print('Excepción capturada: $e');
      throw Exception('Error: $e');
    }
  }

  // Método actualizado para eliminar un producto del menú
  Future<void> removeProductFromMenu(int menuId, MenuProduct menuProduct) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Usar el ID del detalle de menú, no el ID del producto
      final detailId = menuProduct.id; // ID específico del detalle de menú
      
      print('Intentando eliminar detalle de menú con ID: $detailId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/menu/details/$detailId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return; // Operación exitosa
      } else {
        final errorMessage = _parseErrorMessage(response);
        throw Exception('Error al eliminar producto del menú: $errorMessage');
      }
    } catch (e) {
      print('Excepción al eliminar producto: $e');
      throw Exception('Error: $e');
    }
  }

  // Método auxiliar para parsear mensajes de error de la API
  String _parseErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      return errorData['message'] ?? errorData['error'] ?? 'Error desconocido';
    } catch (e) {
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  }
  // Añadir a menu_list_service.dart
Future<void> deleteMenu(int menuId) async {
  try {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }
    
    print('Intentando eliminar menú con ID: $menuId');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/menu/$menuId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Operación exitosa
    } else {
      final errorMessage = _parseErrorMessage(response);
      throw Exception('Error al eliminar el menú: $errorMessage');
    }
  } catch (e) {
    print('Excepción al eliminar menú: $e');
    throw Exception('Error: $e');
  }
}
}