import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/getstarted.dart';
import 'account/login.dart';
import 'account/create_account.dart';
import 'account/forgot_password.dart';
import 'pages/home_page.dart';
import 'pages/admin.dart';

const Color primaryGreen = Color(0xFF4CAF50);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mhyvwiztrsmjfgdiixga.supabase.co',
    anonKey: 'sb_publishable_yFTQXDAqGLlZOywu3RzG6Q_FZNwKCl-',
  );

  runApp(const FoodShareApp());
}

class FoodShareApp extends StatelessWidget {
  const FoodShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlateShare App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: const Color(0xFFF0F0F0),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const CreateAccountScreen(),
        '/forgotPassword': (context) => const ForgotPasswordPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, String>?;
          return MaterialPageRoute(
            builder: (context) => FoodShareHomePage(
              userName: args?['userName'] ?? 'Guest',
              userCategory: args?['userCategory'] ?? 'Donor',
            ),
          );
        }
        if (settings.name == '/admin') {
          return MaterialPageRoute(builder: (context) => const AdminPage());
        }
        return null;
      },
    );
  }
}
