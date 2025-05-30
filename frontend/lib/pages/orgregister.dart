import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admindashboard.dart';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import './Userpages/home_page.dart'; // Make sure this import path is correct
import 'login_page.dart';

Future<String> getLocalIP() async {
  for (var interface in await NetworkInterface.list()) {
    for (var addr in interface.addresses) {
      if (addr.type == InternetAddressType.IPv4 &&
          !addr.address.startsWith('127.') &&
          !addr.address.startsWith('169.254.')) {
        return addr.address;
      }
    }
  }
  return 'localhost';
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController orgController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isRegistering = false;
  String? baseUrl;

  @override
  void initState() {
    super.initState();
    initializeBaseUrl();
  }

  Future<void> initializeBaseUrl() async {
    final host = dotenv.env['BACKEND_URL']!;
    setState(() {
      baseUrl = '$host/api/auth';
      print('Base URL initialized: $baseUrl');
    });
  }

  Future<void> register() async {
    if (baseUrl == null) return;

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'organizationName': orgController.text,
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) => AdminApp(
                // orgName: orgController.text,
                // orgid: responseData['orgid']['_id'],
              ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Registration failed: ${responseData['error']}');
    }
  }

  Future<void> login() async {
    print('Calling: $baseUrl/login');

    if (baseUrl == null) return;

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => AdminApp(
                // orgName: data['org'],
                // orgid: data['orgid']['_id'],
              ),
        ),
      );
    } else {
      String message;
      try {
        final errorData = jsonDecode(response.body);
        message = errorData['error'] ?? response.body;
      } catch (_) {
        message = response.body;
      }
      print('Login failed (${response.statusCode}): $message');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $message')));
    }
  }

  Widget buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isRegistering = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      !isRegistering
                          ? Colors.deepPurpleAccent
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: !isRegistering ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isRegistering = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isRegistering
                          ? Colors.deepPurpleAccent
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: isRegistering ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (baseUrl == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    print('Building AuthPage with baseUrl: $baseUrl');
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildToggleButtons(),
                SizedBox(height: 32),
                if (isRegistering) buildTextField('Name', nameController),
                if (isRegistering) SizedBox(height: 16),
                buildTextField('Email', emailController),
                if (isRegistering) SizedBox(height: 16),
                if (isRegistering)
                  buildTextField('Organization Name', orgController),
                SizedBox(height: 16),
                buildTextField('Password', passwordController, obscure: true),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isRegistering ? register : login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isRegistering ? 'Register' : 'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isRegistering = !isRegistering;
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      text:
                          isRegistering
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: isRegistering ? 'Login' : 'Register',
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                /// 👇 "Continue as User" button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Continue as User',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
