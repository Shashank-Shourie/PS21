import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudentListPage extends StatefulWidget {
  final String admissionType;
  final String orgId;
  final String orgName;
  StudentListPage({required this.admissionType,required this.orgId, required this.orgName});

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();

  List<dynamic> users = [];

  final String? backendUrl = dotenv.env['BACKEND_URL'];

  Future<void> createUser() async {
  final response = await http.post(
    Uri.parse('$backendUrl/user/userregister'),
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      "name": _nameController.text,
      "email": _emailController.text,
      "organizationId": widget.orgId,
    }),
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('User created')));
    _nameController.clear();
    _emailController.clear();
    _organizationController.clear();
    fetchUsers(); // Refresh the list
  } else {
    // Decode the backend error response and show it
    final errorData = json.decode(response.body);
    print('Backend Error: $errorData'); // Logs to console

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create user: ${errorData['error'] ?? 'Unknown error'}')),
    );
  }
}


  Future<void> fetchUsers() async {
    print('Calling $backendUrl/user/userslist');
    final response = await http.post(
      Uri.parse('$backendUrl/user/userslist'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
      "organizationId": widget.orgId,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        // Optionally filter users by admissionType if it's part of the user data
        users =
            json.decode(response.body).toList();
      });
    } else {
      print("Error fetching users");
      print(response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.admissionType} Students')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: createUser, child: Text('Create User')),
            Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user['name']),
                    subtitle: Text(user['email']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
