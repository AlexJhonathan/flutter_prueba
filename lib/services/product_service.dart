import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Product>> getProducts(int? menuId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final uri = menuId != null
          ? Uri.parse('$baseUrl/menu/details/category?menuId=$menuId')
          : Uri.parse('$baseUrl/product');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Añade el token aquí
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Product> products = body.map((dynamic item) => Product.fromJson(item)).toList();
        return products;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada o token inválido');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar los productos: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/product'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Añade el token aquí
      },
      body: json.encode({
        'name': product.name,
        'price': product.price,
        'category': product.category,
        'status': product.status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al añadir el producto');
    }
  }

  Future<void> deleteProduct(int productId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/product/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Añade el token aquí
      },
    );

    if (response.statusCode != 204) { // El código de estado para eliminación exitosa es 204
      throw Exception('Error al eliminar el producto');
    }
  }

  Future<void> updateProduct(Product product) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/product/${product.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Añade el token aquí
      },
      body: json.encode({
        'name': product.name,
        'price': product.price,
        'category': product.category,
        'status': product.status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el producto');
    }
  }
}