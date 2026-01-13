import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
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

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const FoodShareApp(),
    ),
  );
}

class FoodShareApp extends StatelessWidget {
  const FoodShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'PlateShare App',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getThemeData(),
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
      },
    );
  }
}
