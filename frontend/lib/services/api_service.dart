import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.config.dart';

class ApiService {
  final http.Client client;
  final SharedPreferences prefs;

  ApiService({required this.client, required this.prefs});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse(ApiConfig.login),
      body: json.encode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await prefs.setString('token', data['token']);
      return data['user'];
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> uploadDocument(
    File file, 
    String admissionType, 
    String docType,
  ) async {
    final token = prefs.getString('token');
    final request = http.MultipartRequest(
      'POST', 
      Uri.parse('${ApiConfig.documents}/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['admissionType'] = admissionType;
    request.fields['docType'] = docType;
    request.files.add(await http.MultipartFile.fromPath('document', file.path));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Document upload failed');
    }
  }
}