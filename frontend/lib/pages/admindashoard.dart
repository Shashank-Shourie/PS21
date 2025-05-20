import 'package:flutter/material.dart';
import 'studentsListpage.dart';
import 'addnewmember.dart';

void main() => runApp(AdminApp());

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(
            color: Colors.indigo[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(200, 60),
          ),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: Colors.indigo,
          textColor: Colors.black87,
        ),
      ),
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _navigateToStudentList(String admissionType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentListPage(admissionType: admissionType),
      ),
    );
  }

  void _showAccountDetails() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              "Account Details",
              style: TextStyle(
                color: Colors.indigo[900],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Container(
              // Added Container to limit the width
              constraints: BoxConstraints(
                maxWidth: 400,
              ), // Limit max width of dialog
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.account_circle, color: Colors.indigo[900]),
                          SizedBox(width: 8),
                          Expanded(
                            // Added Expanded to make the text wrap
                            child: Text(
                              "Admin: Manideep Reddy",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.business, color: Colors.indigo[900]),
                          SizedBox(width: 8),
                          Expanded(
                            // Added Expanded to make the text wrap
                            child: Text(
                              "Organisation: YourOrg Pvt Ltd",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.email, color: Colors.indigo[900]),
                          SizedBox(width: 8),
                          Expanded(
                            // Added Expanded to make the text wrap
                            child: Text(
                              "Email: admin@yourorg.com",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showChangePasswordDialog();
                },
                child: Text(
                  "Change Password",
                  style: TextStyle(color: Colors.indigo[900]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Close",
                  style: TextStyle(color: Colors.indigo[900]),
                ),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog() {
    final _oldController = TextEditingController();
    final _newController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Change Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Old Password"),
                ),
                TextField(
                  controller: _newController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "New Password"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Password change feature is not yet implemented.",
                      ),
                    ),
                  );
                },
                child: Text("Submit"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
            ],
          ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Panel",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  "YourOrg Pvt Ltd",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text("Add New Member"),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOptions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildOptionButton(
            'TGCET',
            Icons.school,
            () => _navigateToStudentList('TGCET'),
          ),
          SizedBox(height: 20),
          _buildOptionButton(
            'ECET',
            Icons.book,
            () => _navigateToStudentList('ECET'),
          ),
          SizedBox(height: 20),
          _buildOptionButton(
            'OTHERS',
            Icons.more_horiz,
            () => _navigateToStudentList('OTHERS'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(),
      appBar: AppBar(
        title: Text("Organisation Name"),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _showAccountDetails,
          ),
        ],
      ),
      body: _buildMainOptions(),
    );
  }
}
