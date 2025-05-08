import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../widgets/progress_stepper.dart';

class DocumentUploadPage extends StatefulWidget {
  final String admissionType;

  DocumentUploadPage({required this.admissionType});

  @override
  _DocumentUploadPageState createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final List<String> requiredDocs = [
    'Aadhar Card',
    '10th Marksheet',
    '12th Marksheet',
    'Transfer Certificate'
  ];
  Map<String, File?> uploadedDocs = {};
  bool _isLoading = false;

  Future<void> _pickDocument(String docType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        uploadedDocs[docType] = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadDocuments() async {
    setState(() => _isLoading = true);
    
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      for (var entry in uploadedDocs.entries) {
        if (entry.value != null) {
          await api.uploadDocument(
            entry.value!,
            widget.admissionType,
            entry.key,
          );
        }
      }
      Navigator.pushNamed(context, '/application-form');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Documents')),
      body: Column(
        children: [
          ProgressStepper(currentStep: 1),
          Expanded(
            child: ListView.builder(
              itemCount: requiredDocs.length,
              itemBuilder: (context, index) {
                final docType = requiredDocs[index];
                return ListTile(
                  title: Text(docType),
                  trailing: uploadedDocs[docType] != null
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.upload_file),
                  onTap: () => _pickDocument(docType),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: 
                    uploadedDocs.length == requiredDocs.length 
                      ? _uploadDocuments 
                      : null,
                  child: Text('Continue to Application'),
                ),
          ),
        ],
      ),
    );
  }
}