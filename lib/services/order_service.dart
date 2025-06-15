import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderService {
  final String _baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo'; // URL base

  // Método para obtener el token de autenticación
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Método para obtener el ID del usuario actual (mesero)
  Future<int> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    
    if (userId == null) {
      // Si no hay ID guardado, usar un valor predeterminado
      userId = 1; // ID de mesero predeterminado
      await prefs.setInt('userId', userId);
    }
    
    return userId;
  }

  // Método para crear un nuevo pedido
  Future<Map<String, dynamic>> createOrder({
    required int tableId,
    required int branchId,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    // Obtener el ID del mesero
    final waiterId = await getCurrentUserId();
    
    // Generar fecha actual en formato ISO
    final now = DateTime.now();
    final date = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(now);
    
    // Valores predeterminados
    const cookId = 1;
    const status = 1;
    final notes = ""; // Nota vacía por defecto
    final total = 0.0; // Total inicial en 0
    
    final url = Uri.parse('$_baseUrl/api/order/');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'tableId': tableId,
          'waiterId': waiterId,
          'branchId': branchId,
          'cookId': cookId,
          'date': date,
          'notes': notes,
          'total': total,
          'status': status,
        }),
      );

      print('CREATE ORDER RESPONSE: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al crear el pedido: ${response.body}');
      }
    } catch (e) {
      print('ERROR CREANDO PEDIDO: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Método para añadir un producto al pedido
  Future<void> addOrderProduct({
    required int orderId,
    required int productId,
    required int quantity,
    required double subtotal,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final url = Uri.parse('$_baseUrl/api/order/detail/');
    
    try {
      final Map<String, dynamic> requestBody = {
        'orderId': orderId,
        'productId': productId,
        'quantity': quantity,
        'subtotal': subtotal,
      };

      print('ENVIANDO DATOS DE PRODUCTO: $requestBody');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('ADD PRODUCT RESPONSE: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Error al agregar el producto: ${response.body}');
      }
    } catch (e) {
      print('ERROR AÑADIENDO PRODUCTO: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Método para añadir múltiples productos al pedido
  Future<void> addOrderDetails(int orderId, List<Map<String, dynamic>> details) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final url = Uri.parse('$_baseUrl/api/order/detail/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'orderId': orderId,
          'details': details,
        }),
      );

      print('ADD ORDER DETAILS RESPONSE: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al añadir los detalles del pedido: ${response.body}');
      }
    } catch (e) {
      print('ERROR AÑADIENDO DETALLES DEL PEDIDO: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Método para obtener los detalles de un pedido específico
  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final url = Uri.parse('$_baseUrl/api/order/$orderId');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('GET ORDER RESPONSE: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener el pedido: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR OBTENIENDO PEDIDO: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Método para obtener los productos de un pedido
  Future<List<dynamic>> getOrderProducts(int orderId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final url = Uri.parse('$_baseUrl/api/order/detail/$orderId');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('GET PRODUCTS RESPONSE: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('items')) {
          return data['items'] as List;
        } else {
          return [];
        }
      } else {
        throw Exception('Error al obtener los productos: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR OBTENIENDO PRODUCTOS: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Método para obtener los pedidos por sucursal
  Future<List<dynamic>> getOrdersByBranch(int branchId) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('No hay token de autenticación');
  }

  // URL corregida según tu descripción inicial
  final url = Uri.parse('$_baseUrl/api/order/branch/$branchId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('GET ORDERS BY BRANCH RESPONSE: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      throw Exception('Error al obtener los pedidos: ${response.statusCode}');
    }
  } catch (e) {
    print('ERROR OBTENIENDO PEDIDOS POR SUCURSAL: $e');
    throw Exception('Error en la solicitud: $e');
  }
}

  // Método para actualizar un pedido existente
Future<Map<String, dynamic>> updateOrder({
  required int orderId,
  int? cookId,
  String? notes,
  double? total,
  int? status,
}) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('No hay token de autenticación');
  }

  // Si no se proporciona cookId pero necesitamos uno, obtener el usuario actual
  if (cookId == null && status == 2) {
    cookId = await getCurrentUserId(); // Utilizar el ID del usuario actual como cocinero
  }

  // Preparar solo los campos que necesitan actualizarse
  final Map<String, dynamic> updateData = {};
  if (cookId != null) updateData['cookId'] = cookId;
  if (notes != null) updateData['notes'] = notes;
  if (total != null) updateData['total'] = total;
  if (status != null) updateData['status'] = status;

  // Resto del código...


  final url = Uri.parse('$_baseUrl/api/order/$orderId');
  
  print('ENVIANDO DATOS: $updateData');
  
  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updateData),
    );

    print('UPDATE ORDER RESPONSE: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al actualizar el pedido: ${response.statusCode}\nRespuesta: ${response.body}');
    }
  } catch (e) {
    print('ERROR ACTUALIZANDO PEDIDO: $e');
    throw Exception('Error en la solicitud: $e');
  }
}
}