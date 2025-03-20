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
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle), // Account settings icon
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          double circleSize =
              constraints.maxWidth * 0.35; // Adjust size dynamically

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Divider(thickness: 1,height: 1),
              const SizedBox(height: 10,),
              const Text(
                "KMIT\nKeshav Memorial Institute of Technology",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount:
                      constraints.maxWidth > 600
                          ? 3
                          : 2, // Adjust grid for screen width
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildButton(context, "TGCET", TgcetPage(), circleSize),
                    _buildButton(
                      context,
                      "Management",
                      ManagementPage(),
                      circleSize,
                    ),
                    _buildButton(context, "JEE", JeePage(), circleSize),
                    _buildButton(context, "Others", OthersPage(), circleSize),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Widget page,
    double size,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero, // Ensure button takes full size
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
