import 'package:flutter/material.dart';
import '/pages/Userpages/home_page.dart';
// import 'pages/orgregister.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: HomePage(),
      // home: AuthPage(),
    ),
  );
}
