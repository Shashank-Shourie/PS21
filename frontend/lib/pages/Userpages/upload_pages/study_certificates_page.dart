
import 'package:flutter/material.dart';

class StudyCertificatesPage extends StatelessWidget {
  const StudyCertificatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Certificates (6th - 12th)'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: const Center(
        child: Text('Upload PDF for Study Certificates (6th - 12th)'),
      ),
    );
  }
}
