import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tgcet_page.dart';
import 'ecet_page.dart';
import 'others_page.dart';
import '../../models/userData.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../login_page.dart';

// Import the UserData class from login_page.dart

class StudentApp extends StatelessWidget {
  final UserData userData;
  String token;
  StudentApp({Key? key, required this.userData, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
      ),
      home: StudentDashboard(userData: userData,token: token,),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  final UserData? userData;
  String token;
  StudentDashboard({Key? key, this.userData,required this.token}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with TickerProviderStateMixin {
  UserData? currentUser;
  String? baseUrl;
  String organizationName = "Loading...";
  bool isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
    initializeBaseUrl();
  }

  Future<void> initializeBaseUrl() async {
    final host = dotenv.env['BACKEND_URL']!;
    setState(() {
      baseUrl = '$host';
      print('Base URL initialized: $baseUrl');
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  Future<void> _initializeData() async {
    if (widget.userData != null) {
      setState(() => currentUser = widget.userData);
    } else {
      await _loadUserFromStorage();
    }

    if (currentUser != null) {
      await _fetchOrganizationName();
    }
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');

    if (token != null && userData != null) {
      setState(() {
        currentUser = UserData.fromJson(jsonDecode(userData), token);
      });
    }
  }

  Future<void> _fetchOrganizationName() async {
    if (currentUser?.organizationId == null ||
        currentUser?.organizationId.isEmpty == true) {
      setState(() => organizationName = "YourOrg Pvt Ltd");
      return;
    }

    try {
      // Replace with your actual backend URL
      final baseUrl = dotenv.env['BACKEND_URL']; // Get from dotenv
      final response = await http.get(
        Uri.parse('$baseUrl/user/organization/${currentUser!.organizationId}'),
        headers: {
          'Authorization': 'Bearer ${currentUser!.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => organizationName = data['name'] ?? 'YourOrg Pvt Ltd');
      } else {
        setState(() => organizationName = 'YourOrg Pvt Ltd');
      }
    } catch (e) {
      print('Error fetching organization: $e');
      setState(() => organizationName = 'YourOrg Pvt Ltd');
    }
  }

  Future<void> _refreshUserData() async {
    if (currentUser == null || baseUrl == null) return;

    setState(() => isRefreshing = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/details/${currentUser!.id}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentUser = UserData(
            id: data['id'],
            name: data['name'],
            email: data['email'],
            submitted: data['submitted'],
            percentageMatched: data['percentage_matched']?.toDouble() ?? -1.0,
            organizationId: data['organizationId'],
            token: widget.token,
          );
        });

        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode({
          'id': currentUser!.id,
          'name': currentUser!.name,
          'email': currentUser!.email,
          'submitted': currentUser!.submitted,
          'percentage_matched': currentUser!.percentageMatched,
          'organizationId': currentUser!.organizationId,
        }));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status refreshed successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to refresh user data');
      }
    } catch (e) {
      print('Error refreshing user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to refresh status"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => isRefreshing = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void _showAccountDetails() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.account_circle, color: Colors.deepPurple, size: 28),
                SizedBox(width: 8),
                Text(
                  "Account Details",
                  style: TextStyle(
                    color: Colors.deepPurple[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailTile(
                    icon: Icons.person,
                    label: "Name",
                    value: currentUser?.name ?? "Student User",
                  ),
                  _buildDetailTile(
                    icon: Icons.business,
                    label: "Organization",
                    value: organizationName,
                  ),
                  _buildDetailTile(
                    icon: Icons.email,
                    label: "Email",
                    value: currentUser?.email ?? "No email",
                  ),
                  _buildDetailTile(
                    icon: Icons.assignment_turned_in,
                    label: "Submission Status",
                    value:
                        (currentUser?.submitted ?? false)
                            ? "Submitted"
                            : "Pending",
                    valueColor:
                        (currentUser?.submitted ?? false)
                            ? Colors.green
                            : Colors.orange,
                  ),
                  if ((currentUser?.percentageMatched ?? -1) >= 0)
                    _buildDetailTile(
                      icon: Icons.analytics,
                      label: "Match Percentage",
                      value:
                          "${currentUser!.percentageMatched.toStringAsFixed(1)}%",
                      valueColor: Colors.blue,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showChangePasswordDialog();
                },
                icon: Icon(Icons.lock, size: 18),
                label: Text("Change Password"),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close"),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    "Change Password",
                    style: TextStyle(color: Colors.deepPurple[800]),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: oldController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Current Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: newController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: confirmController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirm New Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (newController.text !=
                                    confirmController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Passwords don't match"),
                                    ),
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                // Implement password change API call here
                                await Future.delayed(
                                  Duration(seconds: 2),
                                ); // Simulate API call

                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Password change feature is not yet implemented.",
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                      child:
                          isLoading
                              ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text("Update"),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showUploadDocumentsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.upload_file, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Upload Documents",
                  style: TextStyle(
                    color: Colors.deepPurple[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUploadOption(
                  icon: Icons.school,
                  title: "TGCET",
                  subtitle: "Technical Education Certificate",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (_) => TgcetPage(userData: currentUser),
                        builder: (_) => TgcetPage(UserId: currentUser!.id,token:widget.token,),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildUploadOption(
                  icon: Icons.book,
                  title: "ECET",
                  subtitle: "Engineering Common Entrance Test",
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (_) => EcetPage(userData: currentUser),
                        builder: (_) => EcetPage(UserId: currentUser!.id,token: widget.token,),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildUploadOption(
                  icon: Icons.more_horiz,
                  title: "OTHERS",
                  subtitle: "Additional Documents",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (_) => OthersPage(userData: currentUser),
                        builder: (_) => OthersPage(UserId: currentUser!.id,token: widget.token,),
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              ),
            ],
          ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple, Colors.deepPurple[300]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    (currentUser?.name ?? "S").substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  currentUser?.name ?? "Student User",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  organizationName,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerTile(
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerTile(
                  icon: Icons.person,
                  title: "Profile",
                  onTap: () {
                    Navigator.pop(context);
                    _showAccountDetails();
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.upload_file,
                  title: "Upload Documents",
                  onTap: () {
                    Navigator.pop(context);
                    _showUploadDocumentsDialog();
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Settings feature coming soon")),
                    );
                  },
                ),
                Divider(),
                _buildDrawerTile(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text("Confirm Logout"),
                            content: Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text("Logout"),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      await _logout();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(),
      appBar: AppBar(
        title: Text(organizationName),
        actions: [
          IconButton(
            icon: isRefreshing 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.refresh),
            onPressed: isRefreshing ? null : _refreshUserData,
            tooltip: "Refresh Status",
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("No new notifications")));
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                (currentUser?.name ?? "S").substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: _showAccountDetails,
          ),
          SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.deepPurple, Colors.deepPurple[300]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentUser?.name ?? "Student",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (currentUser?.submitted ?? false)
                              ? "✓ Documents Submitted"
                              : "⏳ Pending Submission",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Stats Section
                if ((currentUser?.percentageMatched ?? -1) >= 0) ...[
                  Text(
                    "Your Statistics",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          icon: Icons.analytics,
                          title: "Match Percentage",
                          value:
                              "${currentUser!.percentageMatched.toStringAsFixed(1)}%",
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatsCard(
                          icon: Icons.assignment_turned_in,
                          title: "Status",
                          value: (currentUser?.submitted ?? false) ? "✓" : "⏳",
                          color:
                              (currentUser?.submitted ?? false)
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                ],

                // Main Action Section
                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),

                Center(
                  child: Container(
                    width: double.infinity,
                    height: 121,
                    child: ElevatedButton(
                      onPressed: _showUploadDocumentsDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: Colors.deepPurple.withOpacity(0.3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 40,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Upload Documents",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Submit your certificates and documents",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
