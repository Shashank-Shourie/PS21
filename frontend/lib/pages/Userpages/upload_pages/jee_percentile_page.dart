
import 'package:flutter/material.dart';

class JeePercentilePage extends StatelessWidget {
  const JeePercentilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JEEPercentile Document'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: const Center(
        child: Text('Upload PDF for JEEPercentile Document'),
      ),
    );
  }
}
