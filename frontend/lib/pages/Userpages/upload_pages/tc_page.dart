
import 'package:flutter/material.dart';

class TCPage extends StatelessWidget {
  const TCPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Certificate'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: const Center(
        child: Text('Upload PDF for Transfer Certificate'),
      ),
    );
  }
}
