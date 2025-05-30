import 'package:flutter/material.dart';
import 'admindashboard.dart'; // Assuming this file exists

class NewAdmissionPage extends StatefulWidget {
  @override
  _NewAdmissionPageState createState() => _NewAdmissionPageState();
}

class _NewAdmissionPageState extends State<NewAdmissionPage> {
  final _emailController = TextEditingController();
  final _admissionNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text('New Admission', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Email ID:', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20.0),
            Text('Admission Number:', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8.0),
            TextField(
              controller: _admissionNumberController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20.0),
            Text('Password:', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8.0),
            TextField(
              controller: _passwordController,
              obscureText: true, // For password input
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 30.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add your logic to handle the new student admission
                  String email = _emailController.text;
                  String admissionNumber = _admissionNumberController.text;
                  String password = _passwordController.text;

                  print(
                    'Email: $email, Admission Number: $admissionNumber, Password: $password',
                  );
                  // You can send this data to your backend or perform other actions

                  // Navigate to AdminDashboard after successful (or attempted) submission
                  Navigator.pushReplacementNamed(
                    context,
                    '/adminDashboard',
                    arguments: {
                      'orgName':
                          '/* Your Actual Org Name */', // Replace with actual value
                      'orgid':
                          '/* Your Actual Org ID */', // Replace with actual value
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  textStyle: TextStyle(fontSize: 18.0),
                ),
                child: Text(
                  'Add Student',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
