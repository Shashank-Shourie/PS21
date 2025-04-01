import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool isDarkMode = false; // Toggle for dark mode
  String username = "User"; // Placeholder username

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text("Username: $username"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _changeUsername(context);
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Dark Mode Toggle
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  _logout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to Change Username
  void _changeUsername(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Username"),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(hintText: "Enter new username"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  username = usernameController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Function to Logout
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(
                  context,
                ); // Navigate back to HomePage after logout
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
