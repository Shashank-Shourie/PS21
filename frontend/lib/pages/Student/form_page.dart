import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  final String extractedText;
  final String UserId;
  final String token;
  const FormPage({
    super.key,
    required this.extractedText,
    required this.UserId,
    required this.token
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  // Data comparison results
  Map<String, ComparisonResult> _comparisonResults = {};
  bool _showComparison = false;

  // Form fields configuration
  final List<FormField> _formFields = [
    FormField('fullName', 'Full Name', TextInputType.name, true),
    FormField('fatherName', 'Father\'s Name', TextInputType.name, true),
    FormField('motherName', 'Mother\'s Name', TextInputType.name, false),
    FormField('dateOfBirth', 'Date of Birth', TextInputType.datetime, true),
    FormField('gender', 'Gender', TextInputType.text, true),
    FormField('aadharNumber', 'Aadhar Number', TextInputType.number, true),
    FormField('mobileNumber', 'Mobile Number', TextInputType.phone, true),
    FormField('email', 'Email Address', TextInputType.emailAddress, false),
    // FormField('address', 'Address', TextInputType.multiline, true),
    FormField('pincode', 'Pincode', TextInputType.number, true),
    FormField(
      'tenthMarks',
      '10th Marks/Percentage',
      TextInputType.number,
      true,
    ),
    FormField(
      'interMarks',
      'Inter Marks/Percentage',
      TextInputType.number,
      true,
    ),
    FormField('eamcetRank', 'EAMCET Rank', TextInputType.number, false),
    FormField('category', 'Category', TextInputType.text, true),
    FormField('income', 'Family Income', TextInputType.number, false),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeControllers();
    _extractAndFillData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (var field in _formFields) {
      _controllers[field.key] = TextEditingController();
      _focusNodes[field.key] = FocusNode();
    }
  }

  void _extractAndFillData() {
    final extractedData = _extractDataFromText(widget.extractedText);

    // Fill form fields with extracted data
    for (var entry in extractedData.entries) {
      if (_controllers.containsKey(entry.key)) {
        _controllers[entry.key]!.text = entry.value;
      }
    }

    setState(() {});
  }

  Future<void> changeSubmitStatus(
    int matchPercentage,
    String userId,
    String token,
  ) async {
    final host = dotenv.env['BACKEND_URL']!;
    final url = Uri.parse('$host/users/update-submission/$userId');
    print(userId);
    print(url);
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Include the JWT token for authenticateToken middleware
        },
        body: jsonEncode({'matchPercentage': matchPercentage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Success: ${data['message']}');
      } else {
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Exception during request: $e');
    }
  }

  Map<String, String> _extractDataFromText(String text) {
    Map<String, String> extractedData = {};

    // Convert text to lowercase for easier matching
    String lowerText = text.toLowerCase();

    // Extract patterns using RegExp
    final patterns = <String, List<RegExp>>{
      'fullName': [
        RegExp(r'name[:\s]*([a-za-z\s]+)', caseSensitive: false),
        RegExp(r'student name[:\s]*([a-za-z\s]+)', caseSensitive: false),
      ],
      'fatherName': [
        RegExp(r'father[\s]*\s*name[:\s]*([a-za-z\s]+)', caseSensitive: false),
        RegExp(r'father[:\s]*([a-za-z\s]+)', caseSensitive: false),
      ],
      'motherName': [
        RegExp(r'mother[\s]*\s*name[:\s]*([a-za-z\s]+)', caseSensitive: false),
        RegExp(r'mother[:\s]*([a-za-z\s]+)', caseSensitive: false),
      ],
      'dateOfBirth': [
        RegExp(
          r'date of birth[:\s]*(\d{1,2}[/-]\d{1,2}[/-]\d{4})',
          caseSensitive: false,
        ),
        RegExp(r'dob[:\s]*(\d{1,2}[/-]\d{1,2}[/-]\d{4})', caseSensitive: false),
        RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{4})'),
      ],
      'aadharNumber': [
        RegExp(r'aadhar[:\s]*(\d{4}\s*\d{4}\s*\d{4})', caseSensitive: false),
        RegExp(r'aadhaar[:\s]*(\d{4}\s*\d{4}\s*\d{4})', caseSensitive: false),
        RegExp(r'(\d{4}\s*\d{4}\s*\d{4})'),
      ],
      'mobileNumber': [
        RegExp(r'mobile[:\s]*(\d{10})', caseSensitive: false),
        RegExp(r'phone[:\s]*(\d{10})', caseSensitive: false),
        RegExp(r'(\d{10})'),
      ],
      'tenthMarks': [
        RegExp(r'10th[:\s]*(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'tenth[:\s]*(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'ssc[:\s]*(\d+\.?\d*)', caseSensitive: false),
      ],
      'interMarks': [
        RegExp(r'inter[:\s]*(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'intermediate[:\s]*(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'12th[:\s]*(\d+\.?\d*)', caseSensitive: false),
      ],
      'eamcetRank': [
        RegExp(r'eamcet[:\s]*rank[:\s]*(\d+)', caseSensitive: false),
        RegExp(r'rank[:\s]*(\d+)', caseSensitive: false),
      ],
      'pincode': [
        RegExp(r'pincode[:\s]*(\d{6})', caseSensitive: false),
        RegExp(r'pin[:\s]*(\d{6})', caseSensitive: false),
      ],
    };

    // Extract gender
    if (lowerText.contains('male') && !lowerText.contains('female')) {
      extractedData['gender'] = 'Male';
    } else if (lowerText.contains('female')) {
      extractedData['gender'] = 'Female';
    }

    // Extract category
    final categories = ['general', 'oc', 'sc', 'st', 'ews'];
    for (String category in categories) {
      if (lowerText.contains(category)) {
        extractedData['category'] = category.toUpperCase();
        break;
      }
    }

    // Apply patterns
    for (var entry in patterns.entries) {
      for (var pattern in entry.value) {
        final match = pattern.firstMatch(text);
        if (match != null && match.group(1) != null) {
          extractedData[entry.key] = match.group(1)!.trim();
          break;
        }
      }
    }

    return extractedData;
  }

  void _compareFormData() {
    final formData = <String, String>{};
    final extractedData = _extractDataFromText(widget.extractedText);

    // Get current form data
    for (var field in _formFields) {
      formData[field.key] = _controllers[field.key]!.text.trim();
    }

    // Compare data
    _comparisonResults.clear();
    for (var field in _formFields) {
      final formValue = formData[field.key] ?? '';
      final extractedValue = extractedData[field.key] ?? '';

      if (formValue.isNotEmpty || extractedValue.isNotEmpty) {
        _comparisonResults[field.key] = ComparisonResult(
          fieldName: field.label,
          formValue: formValue,
          extractedValue: extractedValue,
          isMatch: _isValueMatch(formValue, extractedValue),
        );
      }
    }

    setState(() {
      _showComparison = true;
      _tabController.animateTo(1);
    });
  }

  bool _isValueMatch(String formValue, String extractedValue) {
    if (formValue.isEmpty && extractedValue.isEmpty) return true;
    if (formValue.isEmpty || extractedValue.isEmpty) return false;

    // Normalize values for comparison
    String normalizeValue(String value) {
      return value
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim();
    }

    final normalizedForm = normalizeValue(formValue);
    final normalizedExtracted = normalizeValue(extractedValue);

    // Check for exact match or partial match (for names, addresses)
    return normalizedForm == normalizedExtracted ||
        normalizedForm.contains(normalizedExtracted) ||
        normalizedExtracted.contains(normalizedForm);
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._formFields
                        .map(
                          (field) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextFormField(
                              controller: _controllers[field.key],
                              focusNode: _focusNodes[field.key],
                              keyboardType: field.inputType,
                              maxLines:
                                  field.inputType == TextInputType.multiline
                                      ? 3
                                      : 1,
                              decoration: InputDecoration(
                                labelText: field.label,
                                border: const OutlineInputBorder(),
                                prefixIcon: _getIconForField(field.key),
                              ),
                              validator:
                                  field.isRequired
                                      ? (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return '${field.label} is required';
                                        }
                                        return null;
                                      }
                                      : null,
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _compareFormData();
                  }
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Compare with Extracted Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTab() {
    if (!_showComparison) {
      return const Center(
        child: Text(
          'Fill the form and click "Compare with Extracted Data" to see comparison results.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    final matchedFields =
        _comparisonResults.values.where((r) => r.isMatch).length;
    final totalFields = _comparisonResults.length;
    final matchPercentage =
        totalFields > 0 ? (matchedFields / totalFields * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            color:
                matchPercentage >= 80
                    ? Colors.green[50]
                    : matchPercentage >= 60
                    ? Colors.orange[50]
                    : Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    matchPercentage >= 80
                        ? Icons.check_circle
                        : matchPercentage >= 60
                        ? Icons.warning
                        : Icons.error,
                    color:
                        matchPercentage >= 80
                            ? Colors.green
                            : matchPercentage >= 60
                            ? Colors.orange
                            : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Match: $matchPercentage%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$matchedFields out of $totalFields fields match',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._comparisonResults.entries.map((entry) {
            final result = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  result.isMatch ? Icons.check_circle : Icons.error,
                  color: result.isMatch ? Colors.green : Colors.red,
                ),
                title: Text(result.fieldName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form: ${result.formValue.isEmpty ? "Not provided" : result.formValue}',
                    ),
                    Text(
                      'Extracted: ${result.extractedValue.isEmpty ? "Not found" : result.extractedValue}',
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      matchPercentage >= 50
                          ? () {
                            _showSuccessDialog();
                            changeSubmitStatus(matchPercentage, widget.UserId,widget.token);
                          }
                          : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Icon _getIconForField(String fieldKey) {
    switch (fieldKey) {
      case 'fullName':
      case 'fatherName':
      case 'motherName':
        return const Icon(Icons.person);
      case 'dateOfBirth':
        return const Icon(Icons.calendar_today);
      case 'gender':
        return const Icon(Icons.people);
      case 'aadharNumber':
        return const Icon(Icons.credit_card);
      case 'mobileNumber':
        return const Icon(Icons.phone);
      case 'email':
        return const Icon(Icons.email);
      // case 'address':
      //   return const Icon(Icons.location_on);
      case 'pincode':
        return const Icon(Icons.pin_drop);
      case 'tenthMarks':
      case 'interMarks':
        return const Icon(Icons.school);
      case 'eamcetRank':
        return const Icon(Icons.military_tech);
      case 'category':
        return const Icon(Icons.category);
      case 'income':
        return const Icon(Icons.monetization_on);
      default:
        return const Icon(Icons.text_fields);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.shade50, Colors.white],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Green Tick
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Success Title
                  Text(
                    'Success!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Success Message
                  Text(
                    'Form data has been validated and submitted successfully.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Additional Success Info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data verification complete',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.green.shade200,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Return to Home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification Form'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.edit_document), text: 'Form'),
            Tab(icon: Icon(Icons.compare), text: 'Comparison'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFormTab(), _buildComparisonTab()],
      ),
    );
  }
}

class FormField {
  final String key;
  final String label;
  final TextInputType inputType;
  final bool isRequired;

  FormField(this.key, this.label, this.inputType, this.isRequired);
}

class ComparisonResult {
  final String fieldName;
  final String formValue;
  final String extractedValue;
  final bool isMatch;

  ComparisonResult({
    required this.fieldName,
    required this.formValue,
    required this.extractedValue,
    required this.isMatch,
  });
}
