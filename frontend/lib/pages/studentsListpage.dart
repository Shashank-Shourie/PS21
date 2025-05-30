import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class StudentListPage extends StatefulWidget {
  final String admissionType;

  StudentListPage({required this.admissionType});

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
        "_name": _nameController.text,
        "_email": _emailController.text,
        "_organization": _organizationController.text,
        "admissionType": widget.admissionType, // include admission type
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User created')));
      _nameController.clear();
      _emailController.clear();
      _organizationController.clear();
      fetchUsers(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create user')));
    }
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('$backendUrl/users'));

    if (response.statusCode == 200) {
      setState(() {
        // Optionally filter users by admissionType if it's part of the user data
        users = json.decode(response.body).where((user) {
          return user['admissionType'] == widget.admissionType;
        }).toList();
      });
    } else {
      print("Error fetching users");
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
            TextField(
              controller: _organizationController,
              decoration: InputDecoration(labelText: 'Organization'),
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
