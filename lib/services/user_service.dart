import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  final String baseUrl = 'https://bacake.api.dev.dtt.tja.ucb.edu.bo/api';

  Future<UserResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final user = User.fromJson(userData['user']);
        if (!user.status) {
          return UserResponse(error: 'User is not available');
        }
        final token = userData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return UserResponse(user: user);
      } else {
        return UserResponse(error: 'Login failed');
      }
    } catch (e) {
      return UserResponse(error: e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<UserResponse> addUser(String name, String email, String password, int role, int branch, bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token not found');
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name, 'email': email, 'password': password,
          'role': role, 'branch': branch, 'status': status,
        }),
      );
      if (response.statusCode == 201) {
        return UserResponse.fromJson(json.decode(response.body));
      } else {
        return UserResponse(error: 'Failed to add user');
      }
    } catch (e) {
      return UserResponse(error: e.toString());
    }
  }

  Future<UserResponse> updateUser(int id, String name, String email, String password, int role, int branch, bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token not found');
      final response = await http.put(
        Uri.parse('$baseUrl/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name, 'email': email, 'password': password,
          'role': role, 'branch': branch, 'status': status,
        }),
      );
      if (response.statusCode == 200) {
        return UserResponse.fromJson(json.decode(response.body));
      } else {
        return UserResponse(error: 'Failed to update user');
      }
    } catch (e) {
      return UserResponse(error: e.toString());
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token not found');
      final response = await http.delete(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token not found');
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<User> users = body.map((item) => User.fromJson(item)).toList();
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
}

class UserResponse {
  final String? error;
  final User? user;

  UserResponse({this.error, this.user});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      error: json['error'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}