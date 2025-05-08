import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

class CreateStudentPage extends StatefulWidget {
  @override
  _CreateStudentPageState createState() => _CreateStudentPageState();
}

class _CreateStudentPageState extends State<CreateStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _admissionType;
  bool _isLoading = false;

  final List<String> _admissionTypes = [
    'TGCET',
    'Management',
    'JEE',
    'NRI'
  ];

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.createStudent(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _admissionType!,
      );
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create student: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Student Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) => 
                  value!.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => 
                  value!.isEmpty ? 'Please enter email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => 
                  value!.isEmpty ? 'Please enter phone number' : null,
              ),
              DropdownButtonFormField<String>(
                value: _admissionType,
                decoration: InputDecoration(labelText: 'Admission Type'),
                items: _admissionTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => 
                  setState(() => _admissionType = value),
                validator: (value) => 
                  value == null ? 'Please select admission type' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createStudent,
                    child: Text('Create Account'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}