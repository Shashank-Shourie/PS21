import 'package:flutter/material.dart';

void main() => runApp(AuthApp());

class AuthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthPage());
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController orgController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      if (isLogin) {
        print("Logging in with ${emailController.text}");
      } else {
        print(
          "Registering: ${emailController.text}, Org: ${orgController.text}, Name: ${nameController.text}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: EdgeInsets.all(24),
            width: 370,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(blurRadius: 15, color: Colors.black12)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLogin ? 'Welcome Back 👋' : 'Register your account 📝',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  isLogin ? 'Login to continue' : 'Fill in the details below',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!isLogin)
                        Column(
                          children: [
                            TextFormField(
                              controller: orgController,
                              decoration: InputDecoration(
                                labelText: 'Organisation Name',
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Enter organisation name'
                                          : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Person Name',
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty ? 'Enter your name' : null,
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Enter email' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value!.length < 6
                                    ? 'Minimum 6 characters'
                                    : null,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.deepPurple,
                        ),
                        onPressed: submit,
                        child: Text(
                          isLogin ? 'Login' : 'Register',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: toggleForm,
                        child: Text(
                          isLogin
                              ? "Don't have an account? Register"
                              : "Already have an account? Login",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
