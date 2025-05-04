
import 'package:flutter/material.dart';

class JeeHallTicketPage extends StatelessWidget {
  const JeeHallTicketPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JEEHallTicket'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: const Center(
        child: Text('Upload PDF for JEEHallTicket'),
      ),
    );
  }
}
