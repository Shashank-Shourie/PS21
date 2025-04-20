import 'package:flutter/material.dart';
import 'jee_page.dart';
import 'tgcet_page.dart';
import 'management_page.dart';
import 'others_page.dart';
import 'account_settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(84), // 150% height
        child: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: const Text(
            'Keshav Memorial\nInstitute of Technology',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              height: 1.3,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 👤 Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30, color: Colors.blue),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Welcome, user!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'user@example.com',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white70, thickness: 1),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _drawerTile(Icons.mail_outline, 'Contact us', () {}),
                      _drawerTile(Icons.info_outline, 'About us', () {}),
                      _drawerTile(Icons.settings, 'Settings', () {}),
                      _drawerTile(
                        Icons.logout,
                        'Log out',
                        () {},
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildMenuCard(
              context,
              icon: Icons.school,
              title: "TGCET",
              page: const TgcetPage(),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.business,
              title: "Management",
              page: const ManagementPage(),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.engineering,
              title: "JEE",
              page: const JeePage(),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.more_horiz,
              title: "Others",
              page: const OthersPage(),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Custom drawer tile
  static Widget _drawerTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor:
            isLogout
                ? Colors.red.shade600
                : const Color.fromARGB(255, 23, 23, 23),
        leading: Icon(
          icon,
          color: isLogout ? const Color.fromARGB(255, 255, 0, 0) : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold, // Set text to bold
            color:
                isLogout
                    ? const Color.fromARGB(
                      255,
                      255,
                      0,
                      0,
                    ) // White text for red background
                    : Colors.white, // White text for the rest
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        hoverColor: Colors.white24,
        splashColor: Colors.white30,
      ),
    );
  }

  // 📋 Menu button card
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue.shade900, size: 28),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
