import 'package:flutter/material.dart';
import 'tgcet_page.dart';
import 'ecet_page.dart';
import 'others_page.dart';

void main() => runApp(StudentApp());

class StudentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Dashboard',
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
      home: StudentDashboard(),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  void _showAccountDetails() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Account Details",
              style: TextStyle(color: Colors.indigo[900]),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.indigo),
                    title: Text("Student: Manideep Reddy"),
                  ),
                  ListTile(
                    leading: Icon(Icons.business, color: Colors.indigo),
                    title: Text("Organisation: YourOrg Pvt Ltd"),
                  ),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.indigo),
                    title: Text("Email: student@yourorg.com"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showChangePasswordDialog();
                },
                child: Text("Change Password"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close"),
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

  void _showUploadDocumentsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Upload Documents",
              style: TextStyle(color: Colors.indigo[900]),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.school, color: Colors.white),
                  label: Text("TGCET"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TgcetPage()),
                    );
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.book, color: Colors.white),
                  label: Text("ECET"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EcetPage()),
                    );
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.more_horiz, color: Colors.white),
                  label: Text("OTHERS"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OthersPage()),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
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
                  "Student Panel",
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
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.upload_file),
          label: Text("Upload Documents"),
          onPressed: _showUploadDocumentsDialog,
        ),
      ),
    );
  }
}
