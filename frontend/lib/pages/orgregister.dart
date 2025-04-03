import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admindashoard.dart';
import 'dart:convert';
import 'dart:io';

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

  late String baseUrl; // Declare it as a late variable

  @override
  void initState() {
    super.initState();
    initializeBaseUrl();
  }

  Future<void> initializeBaseUrl() async {
    String ip = await getLocalIP();
    setState(() {
      baseUrl = 'http://$ip:5000/api/auth';
    });
  }

  Future<void> register() async {
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
          builder: (context) => AdminDashboard(orgName: orgController.text),
        ),
      );
    } else {
      print('Registration failed: ${responseData['error']}');
    }
  }

  Future<void> login() async {
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
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboard(orgName: 'Your Org Name'),
        ),
      );
    } else {
      print('Login failed: ${responseData['error']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegistering ? 'Register' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(isRegistering)
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
