import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admindashoard.dart';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

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
    String ip;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final isEmulator = !androidInfo.isPhysicalDevice;

    if (isEmulator) {
      ip = '10.0.2.2'; // Emulator alias to localhost
    } else {
      ip = await getLocalIP(); // Real device
    }

    setState(() {
      baseUrl = 'http://$ip:5000/api/auth';
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
              (context) => AdminDashboard(
                orgName: orgController.text,
                orgid: responseData['orgid']['_id'],
              ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Registration failed: ${responseData['error']}');
    }
  }

  Future<void> login() async {
    if (baseUrl == null) {
      print('Base URL not initialized yet');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) => AdminDashboard(
                orgName: responseData['org'],
                orgid: responseData['orgid']['_id'],
              ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Login failed: ${responseData['error']}');
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
