import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/Auth/login_page.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>(create: (_) => prefs),
        Provider<ApiService>(
          create: (context) => ApiService(
            client: Provider.of(context),
            prefs: Provider.of(context),
          ),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(
            api: Provider.of(context),
            prefs: Provider.of(context),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthService>(
        builder: (context, auth, child) {
          return auth.isAuthenticated
              ? auth.user.role == 'admin'
                  ? AdminDashboard()
                  : AdmissionTypePage()
              : LoginPage();
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/admission-type': (context) => AdmissionTypePage(),
        // Add other routes here
      },
    );
  }
}