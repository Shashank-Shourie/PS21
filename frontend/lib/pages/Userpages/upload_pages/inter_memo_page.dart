
import 'package:flutter/material.dart';

class InterMemoPage extends StatelessWidget {
  const InterMemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inter MemoMemo'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: const Center(
        child: Text('Upload PDF for Inter MemoMemo'),
      ),
    );
  }
}
