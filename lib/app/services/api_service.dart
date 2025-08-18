import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ApiService extends GetxService {
  final String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
  final GetStorage box = GetStorage();
  static const int _timeoutSeconds = 30;

  // Register User
  Future<http.Response> registerUser(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/register');
    try {



      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      ).timeout(Duration(seconds: _timeoutSeconds));
      return response;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Login User
  Future<http.Response> loginUser({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final Map<String, dynamic> body = {
      if (email != null && email.isNotEmpty) 'email': email,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phone_number': phoneNumber,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      ).timeout(Duration(seconds: _timeoutSeconds));
      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Forgot Password
  Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(Duration(seconds: _timeoutSeconds));
      return response;
    } catch (e) {
      throw Exception('Failed to send forgot password request: $e');
    }
  }

  // Fetch Posts (always return map with status + data)
  Future<Map<String, dynamic>> fetchPosts() async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await http.get(url).timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is List) {
          return {'status': true, 'data': jsonResponse};
        } else if (jsonResponse is Map<String, dynamic>) {
          return {
            'status': jsonResponse['status'] ?? true,
            'data': jsonResponse['data'] ?? [],
          };
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // Fetch Posts by Location
  Future<Map<String, dynamic>> fetchPostsByLocation(String location) async {
    final url = Uri.parse('$baseUrl/posts/location');
    try {
      debugPrint("📍 Fetching posts for location: $location"); // print location
      debugPrint("🌐 API URL: $url"); // print URL

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'location': location}),
      ).timeout(Duration(seconds: _timeoutSeconds));

      debugPrint("🔵 Response Status Code: ${response.statusCode}");
      debugPrint("📦 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is List) {
          debugPrint("✅ Response is a List with ${jsonResponse.length} items");
          return {'status': true, 'data': jsonResponse};
        } else if (jsonResponse is Map<String, dynamic>) {
          debugPrint("✅ Response is a Map with keys: ${jsonResponse.keys}");
          return {
            'status': jsonResponse['status'] ?? true,
            'data': jsonResponse['data'] ?? [],
          };
        } else {
          debugPrint("❌ Unexpected response type: ${jsonResponse.runtimeType}");
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to fetch location posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚨 Error in fetchPostsByLocation: $e');
      throw Exception('Failed to fetch location posts: $e');
    }
  }

  // Add Post with Multiple Image Uploads
  Future<http.Response> addPost({
    required String question,
    required String location,
    List<File>? imageFiles,
  }) async {
    final token = box.read('token');
    if (token == null) throw Exception('User not authenticated.');

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/add-posts'));
    request.fields.addAll({'question': question, 'location': location});

    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (var file in imageFiles) {
        request.files.add(await http.MultipartFile.fromPath('images[]', file.path));
      }
    }

    request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});

    try {
      final streamedResponse = await request.send().timeout(Duration(seconds: _timeoutSeconds));
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Logout User
  Future<http.Response> logoutUser(String token) async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      ).timeout(Duration(seconds: _timeoutSeconds));
      return response;
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}
