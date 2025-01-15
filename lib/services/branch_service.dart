import 'package:http/http.dart' as http;
import 'dart:convert';

class BranchResponse {
  final String error;

  BranchResponse({this.error = ''});

  factory BranchResponse.fromJson(Map<String, dynamic> json) {
    return BranchResponse(
      error: json['error'] ?? '',
    );
  }
}

class BranchService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<BranchResponse> addBranch(String nombre, String direccion, int telefono) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/branch/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': nombre,
          'address': direccion,
          'phone': telefono,
        }),
      );

      print('Request body: ${json.encode({
        'name': nombre,
        'address': direccion,
        'phone': telefono,
      })}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return BranchResponse.fromJson(json.decode(response.body));
      } else {
        return BranchResponse(error: 'Failed to add branch');
      }
    } catch (e) {
      return BranchResponse(error: e.toString());
    }
  }
}