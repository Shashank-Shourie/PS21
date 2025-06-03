import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudentListPage extends StatefulWidget {
  final String admissionType;
  final String orgId;
  final String orgName;
  
  StudentListPage({
    required this.admissionType,
    required this.orgId,
    required this.orgName,
  });

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<dynamic> users = [];
  bool isLoading = false;
  bool isCreatingUser = false;

  final String? backendUrl = dotenv.env['BACKEND_URL'];

  Future<void> createUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      isCreatingUser = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/user/userregister'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "organizationId": widget.orgId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Student added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _emailController.clear();
        fetchUsers();
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to add student: ${errorData['error'] ?? 'Unknown error'}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: Please check your connection'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isCreatingUser = false;
      });
    }
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('Calling $backendUrl/user/userslist');
      print('Organization ID: ${widget.orgId}');
      
      final response = await http.post(
        Uri.parse('$backendUrl/user/userslist'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"organizationId": widget.orgId}),
      );
      
      print(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body).toList();
          print(users);
        });
      } else {
        print("Error fetching users");
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load students'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: Please check your connection'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildAddStudentCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_add, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Add New Student',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCreatingUser ? null : createUser,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isCreatingUser
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Adding Student...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Add Student'),
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

  Widget _buildSubmissionStatusChip(Map<String, dynamic> user) {
    // Check if user has submission data
    bool hasSubmitted = user['submitted'] ?? false;
    double? matchPercentage = user['percentage_matched']?.toDouble();
    
    if (!hasSubmitted) {
      return Chip(
        label: Text(
          'Not Submitted',
          style: TextStyle(color: Colors.white, fontSize: 11),
        ),
        backgroundColor: Colors.grey[600],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    
    Color chipColor;
    String statusText;
    
    if (matchPercentage != null) {
      if (matchPercentage >= 75) {
        chipColor = Colors.green;
        statusText = 'Excellent ${matchPercentage.toInt()}%';
      } else if (matchPercentage >= 50) {
        chipColor = Colors.lightGreen;
        statusText = 'Good ${matchPercentage.toInt()}%';
      } else {
        chipColor = Colors.red;
        statusText = 'Poor ${matchPercentage.toInt()}%';
      }
    } else {
      chipColor = Colors.blue;
      statusText = 'Submitted';
    }
    
    return Chip(
      label: Text(
        statusText,
        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> user, int index) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            user['name']?.toString().substring(0, 1).toUpperCase() ?? 'S',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user['email'] ?? 'No email',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            _buildSubmissionStatusChip(user),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 18),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
              value: 'view',
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
              value: 'edit',
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
              value: 'delete',
            ),
          ],
          onSelected: (value) {
            // Handle menu actions
            switch (value) {
              case 'view':
                // Navigate to student details
                break;
              case 'edit':
                // Navigate to edit student
                break;
              case 'delete':
                // Show delete confirmation
                _showDeleteConfirmation(user);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Student'),
            ],
          ),
          content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement delete functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete functionality not implemented yet')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.admissionType} Students',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              widget.orgName,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchUsers,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search functionality coming soon')),
              );
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAddStudentCard(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Students List (${users.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: isLoading && users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading students...'),
                      ],
                    ),
                  )
                : users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No students found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first student using the form above',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchUsers,
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return _buildStudentCard(users[index], index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}