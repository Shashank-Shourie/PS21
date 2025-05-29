import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Form Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple.shade200),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: Colors.deepPurple.shade700),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
      home: EamcetForm(),
    );
  }
}

class EamcetForm extends StatefulWidget {
  @override
  _EamcetFormState createState() => _EamcetFormState();
}

class _EamcetFormState extends State<EamcetForm> {
  final _formKey = GlobalKey<FormState>();
  String? _boardType;

  // Controllers
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  // Add controllers for all form fields you want to send for comparison
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _eamcetRankController = TextEditingController();
  final TextEditingController _eamcetRollNumberController = TextEditingController();
  final TextEditingController _casteController = TextEditingController();

  File? _pickedFile;
  String? _comparisonResult;
  bool _loading = false;

  @override
  void dispose() {
    _dobController.dispose();
    _aadhaarController.dispose();
    _percentageController.dispose();
    _incomeController.dispose();
    _studentNameController.dispose();
    _guardianNameController.dispose();
    _rollNumberController.dispose();
    _yearController.dispose();
    _eamcetRankController.dispose();
    _eamcetRollNumberController.dispose();
    _casteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.deepPurple.shade700,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a PDF file to upload')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _comparisonResult = null;
    });

    try {
      var uri = Uri.parse('http://YOUR_BACKEND_URL/compare-form'); // Replace with your backend URL

      var request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['studentName'] = _studentNameController.text.trim();
      request.fields['dob'] = _dobController.text.trim();
      request.fields['guardianName'] = _guardianNameController.text.trim();
      request.fields['aadhaar'] = _aadhaarController.text.trim();
      request.fields['boardType'] = _boardType ?? '';
      request.fields['rollNumber'] = _rollNumberController.text.trim();
      request.fields['year'] = _yearController.text.trim();
      request.fields['percentage'] = _percentageController.text.trim();
      request.fields['eamcetRank'] = _eamcetRankController.text.trim();
      request.fields['eamcetRollNumber'] = _eamcetRollNumberController.text.trim();
      request.fields['familyIncome'] = _incomeController.text.trim();
      request.fields['caste'] = _casteController.text.trim();

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', _pickedFile!.path));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          _comparisonResult = jsonResponse['comparisonResult'] ?? 'No comparison result';
        });
      } else {
        setState(() {
          _comparisonResult = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _comparisonResult = 'Failed to submit: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Application Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      )),
                  SizedBox(height: 16),

                  // Student Name
                  TextFormField(
                    controller: _studentNameController,
                    decoration: InputDecoration(
                      labelText: 'Student Name',
                      prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter student name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Date of Birth
                  TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth (DD/MM/YYYY)',
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select date of birth';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Guardian's Name
                  TextFormField(
                    controller: _guardianNameController,
                    decoration: InputDecoration(
                      labelText: "Guardian's Name",
                      prefixIcon: Icon(Icons.person_outline, color: Colors.deepPurple),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter guardian name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Aadhaar Number
                  TextFormField(
                    controller: _aadhaarController,
                    decoration: InputDecoration(
                      labelText: 'Aadhaar Number',
                      prefixIcon: Icon(Icons.credit_card, color: Colors.deepPurple),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Aadhaar number';
                      }
                      if (value.length != 12) {
                        return 'Aadhaar number must be 12 digits';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Academic Details Title
                  Text('Academic Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      )),
                  SizedBox(height: 16),

                  // Board Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _boardType,
                    decoration: InputDecoration(
                      labelText: 'Board Type',
                      prefixIcon: Icon(Icons.school, color: Colors.deepPurple),
                    ),
                    items: ['SSC', 'CBSE', 'ICSE']
                        .map((label) => DropdownMenuItem(
                              child: Text(label),
                              value: label,
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _boardType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a board type';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Roll Number
                  TextFormField(
                    controller: _rollNumberController,
                    decoration: InputDecoration(
                      labelText: 'Roll Number',
                      prefixIcon: Icon(Icons.confirmation_number, color: Colors.deepPurple),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter roll number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Year
                  TextFormField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      prefixIcon: Icon(Icons.date_range, color: Colors.deepPurple),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter year';
                      }
                      if (int.tryParse(value) == null || int.parse(value) < 1900 || int.parse(value) > DateTime.now().year) {
                        return 'Please enter a valid year';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Intermediate Percentage
                  TextFormField(
                    controller: _percentageController,
                    decoration: InputDecoration(
                      labelText: 'Intermediate Percentage',
                      prefixIcon: Icon(Icons.percent, color: Colors.deepPurple),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter percentage';
                      }
                      final numValue = num.tryParse(value);
                      if (numValue == null || numValue < 0 || numValue > 100) {
                        return 'Enter a valid percentage (0-100)';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Eamcet Rank
                  TextFormField(
                    controller: _eamcetRankController,
                    decoration: InputDecoration(
                      labelText: 'Eamcet Rank',
                      prefixIcon: Icon(Icons.emoji_events, color: Colors.deepPurple),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Eamcet rank';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Eamcet Roll Number
                  TextFormField(
                    controller: _eamcetRollNumberController,
                    decoration: InputDecoration(
                      labelText: 'Eamcet Roll Number',
                      prefixIcon: Icon(Icons.confirmation_number_outlined, color: Colors.deepPurple),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Eamcet roll number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Family Income
                  TextFormField(
                    controller: _incomeController,
                    decoration: InputDecoration(
                      labelText: 'Family Income',
                      prefixIcon: Icon(Icons.attach_money, color: Colors.deepPurple),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter family income';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Caste
                  TextFormField(
                    controller: _casteController,
                    decoration: InputDecoration(
                      labelText: 'Caste',
                      prefixIcon: Icon(Icons.group, color: Colors.deepPurple),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter caste';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // File Picker Button
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: Icon(Icons.attach_file),
                    label: Text(_pickedFile == null ? 'Select PDF File' : 'Change PDF File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_pickedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Selected file: ${_pickedFile!.path.split('/').last}',
                        style: TextStyle(color: Colors.deepPurple.shade700),
                      ),
                    ),

                  SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submitForm,
                      child: _loading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Submit', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Comparison Result Display
                  if (_comparisonResult != null)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Comparison Result:\n$_comparisonResult',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple.shade900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
