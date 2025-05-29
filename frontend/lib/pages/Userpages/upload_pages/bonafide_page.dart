
import 'package:flutter/material.dart';

class BonafidePage extends StatelessWidget {
  const BonafidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonafide'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: const Center(
        child: Text('Upload PDF for Bonafide'),
      ),
    );
  }
}
