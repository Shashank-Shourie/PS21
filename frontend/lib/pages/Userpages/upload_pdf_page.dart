import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PDFPickerScreen extends StatefulWidget {
  const PDFPickerScreen({super.key});

  @override
  State<PDFPickerScreen> createState() => _PDFPickerScreenState();
}

class _PDFPickerScreenState extends State<PDFPickerScreen> {
  String baseUrl = '';
  String? pdfPath;
  String? extractedText;
  bool isLoading = false;
  String? errorMessage;
  int? pageCount;
  double uploadProgress = 0;
  StreamSubscription<List<int>>? _uploadSubscription;
  StreamSubscription<http.StreamedResponse>? _responseSubscription;

  @override
  void dispose() {
    _uploadSubscription?.cancel();
    _responseSubscription?.cancel();
    super.dispose();
  }

  Future<void> pickAndUploadPDF() async {
    setState(() {
      pdfPath = null;
      extractedText = null;
      errorMessage = null;
      pageCount = null;
      uploadProgress = 0;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      final fileSize = result.files.single.size;
      if (fileSize > 10 * 1024 * 1024) {
        setState(() {
          errorMessage = 'File too large (max 10MB)';
        });
        return;
      }

      setState(() {
        pdfPath = result.files.single.path;
        isLoading = true;
      });

      await uploadPDF(File(pdfPath!));
    } catch (e) {
      setState(() {
        errorMessage = 'File selection failed: ${e.toString()}';
      });
    }
  }

  Future<void> initializeBaseUrl() async {
    final host = dotenv.env['BACKEND_URL']!;
    setState(() {
      // use HTTPS and no port
      baseUrl = '$host/extract/extract-text';
      print('Base URL initialized: $baseUrl');
    });
  }

  Future<void> uploadPDF(File file) async {
    try {
      final host = dotenv.env['BACKEND_URL'];
      if (host == null || host.isEmpty) {
        throw Exception('BACKEND_URL is not set in .env file');
      }

      var uri = Uri.parse('$host/extract/extract-text');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      setState(() {
        uploadProgress = 0;
      });

      var client = http.Client();
      var streamedResponse = await client.send(request);

      // Optional: track upload progress
      final contentLength = streamedResponse.contentLength ?? 0;
      int bytesReceived = 0;

      final completer = Completer<http.Response>();
      final responseBytes = <int>[];

      streamedResponse.stream.listen(
        (chunk) {
          responseBytes.addAll(chunk);
          bytesReceived += chunk.length;
          if (contentLength > 0) {
            setState(() {
              uploadProgress = bytesReceived / contentLength;
            });
          }
        },
        onDone: () {
          final response = http.Response.bytes(
            responseBytes,
            streamedResponse.statusCode,
            headers: streamedResponse.headers,
            request: streamedResponse.request,
          );
          completer.complete(response);
        },
        onError: (error) {
          completer.completeError(error);
        },
        cancelOnError: true,
      );

      final response = await completer.future;

      if (kDebugMode) {
        print('Server response: ${response.body}');
        print('Status code: ${response.statusCode}');
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        throw FormatException('Invalid server response: ${response.body}');
      }

      if (response.statusCode == 200) {
        setState(() {
          extractedText = decoded['extractedText'] ?? 'No text found';
          pageCount = decoded['pageCount'];
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage =
              decoded['error'] ??
              'Server error (Status: ${response.statusCode})';
          if (decoded['details'] != null) {
            errorMessage = '$errorMessage\nDetails: ${decoded['details']}';
          }
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        errorMessage = 'Request timeout - server took too long to respond';
      });
    } on FormatException catch (e) {
      setState(() {
        errorMessage = 'Data format error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Upload failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Text Extraction"),
        actions: [
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircularProgressIndicator(
                value: uploadProgress > 0 ? uploadProgress : null,
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickAndUploadPDF,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('SELECT PDF', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            if (isLoading && uploadProgress > 0)
              LinearProgressIndicator(
                value: uploadProgress,
                backgroundColor: Colors.grey[200],
              ),
            if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (pageCount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Extracted from $pageCount page(s)',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (extractedText != null)
              Expanded(
                child: Card(
                  margin: const EdgeInsets.only(top: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        extractedText!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
