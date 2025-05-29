import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login_page.dart'; // import the actual AuthPage here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await dotenv.load(fileName: "assets/.env"); // optional if used
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(), // this should work now
    );
  }
}
