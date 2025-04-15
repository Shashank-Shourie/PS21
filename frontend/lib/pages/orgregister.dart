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

  String? baseUrl; // Nullable now

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboard(orgName: orgController.text,orgid: responseData['orgid']['_id'],),
        ),
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

    print("Login called");

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    final responseData = jsonDecode(response.body);
    print('Login Response: $responseData');
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboard(orgName: responseData['org'], orgid: responseData['orgid']['_id'],),
        ),
      );
    } else {
      print('Login failed: ${responseData['error']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while baseUrl is being initialized
    if (baseUrl == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(isRegistering ? 'Register' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRegistering)
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            if (isRegistering)
              TextField(
                controller: orgController,
                decoration: InputDecoration(labelText: 'Organization Name'),
              ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isRegistering) {
                  register();
                } else {
                  login();
                }
              },
              child: Text(isRegistering ? 'Register' : 'Login'),
            ),
            SwitchListTile(
              title: Text(
                isRegistering
                    ? 'Already have an account? Login'
                    : "Don't have an account? Register",
              ),
              value: isRegistering,
              onChanged: (value) {
                setState(() {
                  isRegistering = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
