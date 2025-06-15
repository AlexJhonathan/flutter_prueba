import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/branch_model.dart';

class BranchService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<List<Branch>> getBranches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) throw Exception('Token not found');

      final response = await http.get(
        Uri.parse('$baseUrl/branch/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Branch> branches = body.map((dynamic item) => Branch.fromJson(item)).toList();
        return branches;
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  Future<void> deleteBranch(int branchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) throw Exception('Token not found');

      final response = await http.delete(
        Uri.parse('$baseUrl/branch/$branchId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete branch');
      }
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }

  Future<void> updateBranch(int branchId, String name, String address, int phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) throw Exception('Token not found');

      final response = await http.put(
        Uri.parse('$baseUrl/branch/$branchId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'address': address,
          'phone': phone,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update branch');
      }
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  Future<UserResponse> addBranch(String name, String address, int phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) throw Exception('Token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/branch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'address': address,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        return UserResponse.fromJson(json.decode(response.body));
      } else {
        return UserResponse(error: 'Failed to add branch');
      }
    } catch (e) {
      return UserResponse(error: e.toString());
    }
  }
}

class UserResponse {
  final String error;

  UserResponse({this.error = ''});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      error: json['error'] ?? '',
    );
  }
}