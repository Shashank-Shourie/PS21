import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'form_page.dart';

class PDFPickerScreen extends StatefulWidget {
  const PDFPickerScreen({super.key});

  @override
  State<PDFPickerScreen> createState() => _PDFPickerScreenState();
}

class _PDFPickerScreenState extends State<PDFPickerScreen> {
  String baseUrl = '';
  List<PDFDocument> selectedPDFs = [];
  bool isLoading = false;
  String? errorMessage;
  double uploadProgress = 0;
  int currentProcessingIndex = 0;
  StreamSubscription<List<int>>? _uploadSubscription;
  StreamSubscription<http.StreamedResponse>? _responseSubscription;

  @override
  void initState() {
    super.initState();
    initializeBaseUrl();
  }

  @override
  void dispose() {
    _uploadSubscription?.cancel();
    _responseSubscription?.cancel();
    super.dispose();
  }

  Future<void> pickPDFs() async {
    setState(() {
      errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result == null) return;

      List<PDFDocument> newPDFs = [];
      for (var file in result.files) {
        if (file.size > 10 * 1024 * 1024) {
          setState(() {
            errorMessage = 'File ${file.name} is too large (max 10MB)';
          });
          return;
        }
        
        newPDFs.add(PDFDocument(
          name: file.name,
          path: file.path!,
          size: file.size,
          status: PDFStatus.selected,
        ));
      }

      setState(() {
        selectedPDFs.addAll(newPDFs);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'File selection failed: ${e.toString()}';
      });
    }
  }

  Future<void> initializeBaseUrl() async {
    final host = dotenv.env['BACKEND_URL']!;
    setState(() {
      baseUrl = '$host/extract/extract-text';
      if (kDebugMode) print('Base URL initialized: $baseUrl');
    });
  }

  Future<void> processAllPDFs() async {
    if (selectedPDFs.isEmpty) return;

    setState(() {
      isLoading = true;
      uploadProgress = 0;
      currentProcessingIndex = 0;
      errorMessage = null;
    });

    for (int i = 0; i < selectedPDFs.length; i++) {
      setState(() {
        currentProcessingIndex = i;
        selectedPDFs[i] = selectedPDFs[i].copyWith(status: PDFStatus.processing);
      });

      try {
        await uploadPDF(File(selectedPDFs[i].path), i);
        setState(() {
          selectedPDFs[i] = selectedPDFs[i].copyWith(status: PDFStatus.completed);
        });
      } catch (e) {
        setState(() {
          selectedPDFs[i] = selectedPDFs[i].copyWith(
            status: PDFStatus.failed,
            errorMessage: e.toString(),
          );
        });
      }

      // Update overall progress
      setState(() {
        uploadProgress = (i + 1) / selectedPDFs.length;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> uploadPDF(File file, int index) async {
    try {
      final host = dotenv.env['BACKEND_URL'];
      if (host == null || host.isEmpty) {
        throw Exception('BACKEND_URL is not set in .env file');
      }

      var uri = Uri.parse('$host/extract/extract-text');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var client = http.Client();
      var streamedResponse = await client.send(request);

      final contentLength = streamedResponse.contentLength ?? 0;
      int bytesReceived = 0;
      final completer = Completer<http.Response>();
      final responseBytes = <int>[];

      streamedResponse.stream.listen(
        (chunk) {
          responseBytes.addAll(chunk);
          bytesReceived += chunk.length;
          if (contentLength > 0) {
            // Update individual file progress (this could be used for per-file progress)
            double fileProgress = bytesReceived / contentLength;
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
        print('Server response for ${file.path}: ${response.body}');
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
          selectedPDFs[index] = selectedPDFs[index].copyWith(
            extractedText: decoded['extractedText'] ?? 'No text found',
            pageCount: decoded['pageCount'],
          );
        });
      } else {
        String errorMsg = decoded['error'] ?? 'Server error (Status: ${response.statusCode})';
        if (decoded['details'] != null) {
          errorMsg = '$errorMsg\nDetails: ${decoded['details']}';
        }
        throw Exception(errorMsg);
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout - server took too long to respond');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  void removePDF(int index) {
    setState(() {
      selectedPDFs.removeAt(index);
    });
  }

  void clearAllPDFs() {
    setState(() {
      selectedPDFs.clear();
      errorMessage = null;
    });
  }

  String getCombinedExtractedText() {
    List<String> extractedTexts = [];
    
    for (int i = 0; i < selectedPDFs.length; i++) {
      PDFDocument pdf = selectedPDFs[i];
      if (pdf.extractedText != null && pdf.extractedText!.isNotEmpty) {
        extractedTexts.add('--- Document ${i + 1}: ${pdf.name} ---\n${pdf.extractedText!}');
      }
    }
    
    return extractedTexts.join('\n\n');
  }

  bool get hasCompletedPDFs {
    return selectedPDFs.any((pdf) => pdf.status == PDFStatus.completed && pdf.extractedText != null);
  }

  int get totalPages {
    return selectedPDFs.fold(0, (sum, pdf) => sum + (pdf.pageCount ?? 0));
  }

  Widget _buildPDFItem(PDFDocument pdf, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildStatusIcon(pdf.status),
        title: Text(
          pdf.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${(pdf.size / 1024 / 1024).toStringAsFixed(2)} MB'),
            if (pdf.pageCount != null)
              Text('Pages: ${pdf.pageCount}', style: TextStyle(color: Colors.green[700])),
            if (pdf.errorMessage != null)
              Text(pdf.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: isLoading ? null : () => removePDF(index),
        ),
        isThreeLine: pdf.pageCount != null || pdf.errorMessage != null,
      ),
    );
  }

  Widget _buildStatusIcon(PDFStatus status) {
    switch (status) {
      case PDFStatus.selected:
        return const Icon(Icons.description, color: Colors.blue);
      case PDFStatus.processing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case PDFStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case PDFStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Text Extraction"),
        actions: [
          if (selectedPDFs.isNotEmpty && !isLoading)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: clearAllPDFs,
              tooltip: 'Clear All',
            ),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : pickPDFs,
                    icon: const Icon(Icons.add),
                    label: const Text('SELECT PDFs'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (selectedPDFs.isNotEmpty && !isLoading) ? processAllPDFs : null,
                    icon: const Icon(Icons.upload),
                    label: const Text('PROCESS ALL'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (isLoading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Processing ${currentProcessingIndex + 1} of ${selectedPDFs.length} files...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

            if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (selectedPDFs.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected PDFs (${selectedPDFs.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasCompletedPDFs)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Total pages extracted: $totalPages',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedPDFs.length,
                        itemBuilder: (context, index) {
                          return _buildPDFItem(selectedPDFs[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),

            if (hasCompletedPDFs)
              Column(
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormPage(
                              extractedText: getCombinedExtractedText(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('PROCEED TO FORM'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class PDFDocument {
  final String name;
  final String path;
  final int size;
  final PDFStatus status;
  final String? extractedText;
  final int? pageCount;
  final String? errorMessage;

  PDFDocument({
    required this.name,
    required this.path,
    required this.size,
    required this.status,
    this.extractedText,
    this.pageCount,
    this.errorMessage,
  });

  PDFDocument copyWith({
    String? name,
    String? path,
    int? size,
    PDFStatus? status,
    String? extractedText,
    int? pageCount,
    String? errorMessage,
  }) {
    return PDFDocument(
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      status: status ?? this.status,
      extractedText: extractedText ?? this.extractedText,
      pageCount: pageCount ?? this.pageCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum PDFStatus {
  selected,
  processing,
  completed,
  failed,
}