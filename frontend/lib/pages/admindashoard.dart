import 'package:flutter/material.dart';
import 'createform.dart';
import 'orgregister.dart';

class AdminDashboard extends StatelessWidget {
  final String orgName;
  final String orgid;
  const AdminDashboard({super.key, required this.orgName, required this.orgid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(orgName),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                // Navigate to Change Password Page
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Add New Member'),
              onTap: () {
                // Navigate to Add Member Page
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                ); // Navigate back to login page
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateForm()),
            );
          },
          child: Text('Create Form'),
        ),
      ),
    );
  }
}
