
import 'package:flutter/material.dart';

class AadharPage extends StatelessWidget {
  const AadharPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aadhar Card'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: const Center(
        child: Text('Upload PDF for Aadhar Card'),
      ),
    );
  }
}
