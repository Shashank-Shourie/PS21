import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admindashoard.dart';
import 'dart:convert';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController orgController = TextEditingController();
  bool isRegistering = false;
  final String baseUrl =
      'http://192.168.81.67:5000/api/auth'; // Change this to your backend URL

  Future<void> register() async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'organizationName': orgController.text,
        'name': 'User',
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
