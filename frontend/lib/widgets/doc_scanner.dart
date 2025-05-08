import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DocScanner extends StatefulWidget {
  final Function(File) onScanComplete;

  DocScanner({required this.onScanComplete});

  @override
  _DocScannerState createState() => _DocScannerState();
}

class _DocScannerState extends State<DocScanner> {
  File? _scannedDoc;
  bool _isLoading = false;

  Future<void> _scanDocument() async {
    setState(() => _isLoading = true);
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() => _scannedDoc = file);
        widget.onScanComplete(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_scannedDoc != null)
          Image.file(_scannedDoc!, height: 200)
        else
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(child: Text('No document scanned')),
          ),
        SizedBox(height: 16),
        _isLoading
          ? CircularProgressIndicator()
          : ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text(_scannedDoc == null ? 'Scan Document' : 'Rescan'),
              onPressed: _scanDocument,
            ),
      ],
    );
  }
}
