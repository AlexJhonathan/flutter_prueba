import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/supply_detail_model.dart';

class SupplyService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<SupplyDetail>> getSupplyDetails({
    required int branchId,
    int? supplyId,
    DateTime? date,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final queryParameters = {
        'branchId': branchId.toString(),
        if (supplyId != null) 'supplyId': supplyId.toString(),
        if (date != null) 'date': date.toIso8601String(),
      };

      final uri = Uri.parse('$baseUrl/supply/').replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => SupplyDetail.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar los detalles de insumos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar los detalles de insumos: $e');
    }
  }

  // Método para registrar una compra
  Future<void> registrarCompra(Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final uri = Uri.parse('$baseUrl/supply/');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage;
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? 'Error al registrar la compra';
        } catch (e) {
          errorMessage = 'Error: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error al registrar la compra: $e');
    }
  }
  
  // Método para actualizar el consumo de un insumo
  Future<void> actualizarConsumo(Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      
      final uri = Uri.parse('$baseUrl/supply/');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage;
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? 'Error al actualizar el consumo';
        } catch (e) {
          errorMessage = 'Error: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error al actualizar el consumo: $e');
    }
  }
  
  // Método para obtener insumos por categoría
  Future<List<Map<String, dynamic>>> obtenerInsumosPorCategoria(int branchId, String category) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final uri = Uri.parse('$baseUrl/supply/type').replace(
        queryParameters: {'category': category}
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          if (jsonResponse is List) {
            return List<Map<String, dynamic>>.from(jsonResponse);
          } else if (jsonResponse is Map && jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
            return List<Map<String, dynamic>>.from(jsonResponse['data']);
          } else {
            return [];
          }
        }
      } else {
        String errorDetail = '';
        try {
          final errorJson = json.decode(response.body);
          errorDetail = errorJson['message'] ?? errorJson.toString();
        } catch (e) {
          errorDetail = response.body;
        }
        
        throw Exception('Error al cargar los insumos por categoría: ${response.statusCode} - $errorDetail');
      }
    } catch (e) {
      throw Exception('Error al cargar los insumos por categoría: $e');
    }
  }
  
  // Método mejorado para obtener detalles de un insumo específico por ID
  Future<SupplyDetail?> getSupplyDetailById(int supplyId, int branchId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Construir la URL con los parámetros correctos
      final uri = Uri.parse('$baseUrl/supply/').replace(
        queryParameters: {
          'supplyId': supplyId.toString(),
          'branchId': branchId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Si la respuesta es una lista, tomar el primer elemento
        if (responseData is List && responseData.isNotEmpty) {
          return SupplyDetail.fromJson(responseData[0]);
        } 
        // Si la respuesta ya es un objeto único
        else if (responseData is Map<String, dynamic>) {
          return SupplyDetail.fromJson(responseData);
        }
        // Si no encontró resultados
        return null;
      } else {
        throw Exception('Error al obtener detalle del insumo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener detalle del insumo: $e');
    }
  }
}