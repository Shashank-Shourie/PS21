import 'package:flutter/material.dart';

class Student {
  final String name;
  final String email;
  final String phone;
  final String password;
  final bool submitted;

  Student({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.submitted = true,
  });
}

class StudentListPage extends StatefulWidget {
  final String admissionType;

  StudentListPage({required this.admissionType});

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final Map<String, List<Student>> studentsByType = {
    'TGCET': [
      Student(
        name: 'Arjun',
        email: 'arjun@example.com',
        phone: '1234567890',
        password: 'pass1',
        submitted: true,
      ),
      Student(
        name: 'Sita',
        email: 'sita@example.com',
        phone: '9998887770',
        password: 'pass2',
        submitted: false,
      ),
    ],
    'ECET': [
      Student(
        name: 'Ravi',
        email: 'ravi@example.com',
        phone: '8887776660',
        password: 'pass3',
        submitted: true,
      ),
    ],
    'OTHERS': [],
  };

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool showSubmitted = true;

  void _showAddStudentDialog() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add New Student'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Enter name' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator:
                          (val) =>
                              val == null || !val.contains('@')
                                  ? 'Enter valid email'
                                  : null,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      validator:
                          (val) =>
                              val == null || val.length < 10
                                  ? 'Enter valid phone'
                                  : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator:
                          (val) =>
                              val == null || val.length < 4
                                  ? 'Enter min 4 characters'
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      studentsByType[widget.admissionType]?.add(
                        Student(
                          name: _nameController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                          password: _passwordController.text,
                          submitted: false, // default
                        ),
                      );
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: student.submitted ? Colors.green : Colors.orange,
          child: Text(student.name[0], style: TextStyle(color: Colors.white)),
        ),
        title: Text(student.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${student.email}"),
            Text("Phone: ${student.phone}"),
            Text("Submitted: ${student.submitted ? 'Yes' : 'No'}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = studentsByType[widget.admissionType] ?? [];
    final displayedStudents =
        students.where((s) => s.submitted == showSubmitted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.admissionType} Students"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _showAddStudentDialog,
              icon: Icon(Icons.person_add),
              label: Text("Add New Student"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12),
            ToggleButtons(
              isSelected: [showSubmitted, !showSubmitted],
              onPressed: (index) {
                setState(() {
                  showSubmitted = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Colors.indigo,
              color: Colors.indigo,
              constraints: BoxConstraints(minWidth: 100, minHeight: 40),
              children: [Text("Submitted"), Text("Pending")],
            ),
            SizedBox(height: 12),
            Expanded(
              child:
                  displayedStudents.isEmpty
                      ? Center(
                        child: Text(
                          "No ${showSubmitted ? 'submitted' : 'pending'} students.",
                        ),
                      )
                      : ListView.builder(
                        itemCount: displayedStudents.length,
                        itemBuilder:
                            (context, index) =>
                                _buildStudentCard(displayedStudents[index]),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
