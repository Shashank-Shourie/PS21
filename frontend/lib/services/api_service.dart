// Create a new file: lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://your-backend-url.com/api'; // Replace with your actual backend URL
  
  // Update user submission status
  static Future<Map<String, dynamic>> updateSubmissionStatus({
    required String userId,
    required int matchPercentage,
  }) async {
    try {
      // Get stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/update-submission/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'matchPercentage': matchPercentage,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to update submission status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}