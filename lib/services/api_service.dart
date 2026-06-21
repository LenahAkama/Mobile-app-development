import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<User>> fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load users: ${response.statusCode}');
      }

      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/posts?_limit=10'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }

      final List<dynamic> jsonList = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }
}
