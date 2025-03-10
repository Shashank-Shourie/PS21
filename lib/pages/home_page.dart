import 'package:flutter/material.dart';
import 'jee_page.dart'; // Import the page files
import 'tgcet_page.dart';
import 'management_page.dart';
import 'others_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle), // Account settings icon
            onPressed: () {
              // Navigate to account settings page
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "KMIT\nKeshav Memorial Institute of Technology",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildButton(context, "TGCET", TgcetPage()),
              _buildButton(context, "Management", ManagementPage()),
              _buildButton(context, "JEE", JeePage()),
              _buildButton(context, "Others", OthersPage()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(text),
    );
  }
}
