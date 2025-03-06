import 'package:flutter/material.dart';
import 'upload_pdf_page.dart'; // Import the Upload Files page

class OthersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Others Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Others",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PDFPickerScreen()),
                );
              },
              child: Text("Go to Upload Files Page"),
            ),
          ],
        ),
      ),
    );
  }
}
