import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuResponse {
  final String error;

  MenuResponse({this.error = ''});

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      error: json['error'] ?? '',
    );
  }
}

class MenuService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<MenuResponse> createMenu(String name, int branchId, int status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu/'),  // Added trailing slash
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'branchId': branchId,  // Changed from branchID to branchId
          'status': status,
        }),
      );

      print('Request body: ${json.encode({
        'name': name,
        'branchId': branchId,
        'status': status,
      })}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {  // Changed from 200 to 201 for POST creation
        return MenuResponse.fromJson(json.decode(response.body));
      } else {
        return MenuResponse(error: 'Failed to create menu: ${response.body}');
      }
    } catch (e) {
      return MenuResponse(error: e.toString());
    }
  }
}