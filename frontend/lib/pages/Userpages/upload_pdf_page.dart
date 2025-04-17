import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PDFPickerScreen(),
    );
  }
}

class PDFPickerScreen extends StatefulWidget {
  const PDFPickerScreen({super.key});
  
  @override
  State<PDFPickerScreen> createState() => _PDFPickerScreenState();
}

class _PDFPickerScreenState extends State<PDFPickerScreen> {
  String? pdfPath; // To store the picked PDF file path

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Restrict to PDF files
    );

    if (result != null) {
      setState(() {
        pdfPath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick and View PDF")),
      body: Center(
        child:
            pdfPath == null
                ? const Text("No PDF selected yet")
                : SizedBox(height: 600, child: PDFView(filePath: pdfPath!)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickPDF,
        tooltip: "Pick PDF",
        child: const Icon(Icons.attach_file),
      ),
    );
  }
}
