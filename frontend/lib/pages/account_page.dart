// account_page.dart
import 'package:flutter/material.dart';

class AdminAccountSettingsPage extends StatefulWidget {
  final int? initialTab;
  const AdminAccountSettingsPage({super.key, this.initialTab = 0});

  @override
  _AdminAccountSettingsPageState createState() =>
      _AdminAccountSettingsPageState();
}

class _AdminAccountSettingsPageState extends State<AdminAccountSettingsPage> {
  String username = "Admin"; // Replace with actual admin username
  String email = "admin@example.com"; // Replace with actual admin email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profile Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.person,
              label: "Username",
              value: username,
              onEdit: () => _changeUsername(context),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.email,
              label: "Email",
              value: email,
              onEdit: null,
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: const Text("Change Password"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  _changePassword(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    void Function()? onEdit,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text("$label: $value"),
          trailing:
              onEdit != null
                  ? IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: onEdit,
                  )
                  : null,
        ),
      ),
    );
  }

  void _changeUsername(BuildContext context) {
    TextEditingController usernameController = TextEditingController(
      text: username,
    );
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
                if (usernameController.text.trim().isNotEmpty) {
                  setState(() {
                    username = usernameController.text.trim();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _changePassword(BuildContext context) {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Old Password"),
                ),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "New Password"),
                ),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirm New Password",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String newPass = newPasswordController.text;
                String confirmPass = confirmPasswordController.text;

                if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("New passwords do not match")),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password changed successfully"),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("Change"),
            ),
          ],
        );
      },
    );
  }
}
