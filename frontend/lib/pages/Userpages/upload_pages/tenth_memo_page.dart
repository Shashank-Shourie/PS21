
import 'package:flutter/material.dart';

class TenthMemoPage extends StatelessWidget {
  const TenthMemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('10th Memo'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: const Center(
        child: Text('Upload PDF for 10th Memo'),
      ),
    );
  }
}
