import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// --- Shared Constants ---
const Color primaryGreen = Color(0xFF4CAF50);
const Color darkGreen = Color(0xFF388E3C);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  /// Input Field Builder
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// --- Firebase Login Function ---
  Future<void> _performLogin() async {
    setState(() => _errorMessage = '');

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email and password';
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      // Sign in and catch any errors from Supabase
      AuthResponse res;
      try {
        res = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        // ignore: avoid_print
        print('Supabase login error: $e');
        final err = e.toString().toLowerCase();
        var userMsg = 'Login failed: ${e.toString()}';
        if (err.contains('email_address_invalid') ||
            (err.contains('invalid') && err.contains('email')) ||
            err.contains('email address')) {
          userMsg =
              'Invalid email address. Try using a different email (e.g., at least 3 characters before the @) or check Supabase settings.';
        }
        setState(() {
          _errorMessage = userMsg;
        });
        return;
      }

      final session = (res?.session) ?? supabase.auth.currentSession;
      if (session == null) {
        setState(() {
          _errorMessage =
              'Login failed: no session returned (check email confirmation)';
        });
        return;
      }

      final userId = session.user!.id;

      final prefs = await SharedPreferences.getInstance();

      // Fetch profile (maybeSingle returns the row or null)
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        // Try to create the profile on first successful login using any locally saved values.
        final prefsLocal = await SharedPreferences.getInstance();
        final savedName = prefsLocal.getString('userName') ?? email;
        final savedCategory = prefsLocal.getString('userCategory') ?? 'Donor';

        try {
          final inserted = await supabase
              .from('profiles')
              .insert({
                'id': userId,
                'email': email,
                'full_name': savedName,
                'category': savedCategory,
              })
              .select()
              .maybeSingle();

          if (inserted == null) {
            setState(() {
              _errorMessage = 'Profile not found and creation failed.';
            });
            return;
          }

          final userName = (inserted['full_name'] ?? savedName) as String;
          final userCategory =
              (inserted['category'] ?? savedCategory) as String;

          await prefsLocal.setString('userCategory', userCategory);
          await prefsLocal.setString('userName', userName);

          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: {'userName': userName, 'userCategory': userCategory},
          );

          return;
        } catch (e) {
          setState(() {
            _errorMessage = 'Profile creation failed: $e';
          });
          return;
        }
      }

      final userName = (profile['full_name'] ?? email) as String;
      final userCategory = (profile['category'] ?? 'Donor') as String;
      final isAdmin = profile['is_admin'] as bool? ?? false;

      await prefs.setString('userCategory', userCategory);
      await prefs.setString('userName', userName);
      await prefs.setBool('isAdmin', isAdmin);

      if (!mounted) return;

      // Route to admin dashboard if user is admin
      if (isAdmin) {
        // Verify admin password: prefer server-stored `admin_password` in profile;
        // fallback to a fixed constant (change this before production).
        final profileAdminPassword = profile['admin_password'] as String?;
        const fallbackAdminPassword = 'admin123';

        if (profileAdminPassword != null) {
          if (password != profileAdminPassword) {
            setState(() {
              _errorMessage = 'Admin password is incorrect.';
            });
            return;
          }
        } else {
          if (password != fallbackAdminPassword) {
            setState(() {
              _errorMessage = 'Admin password is incorrect.';
            });
            return;
          }
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin',
          (route) => false,
          arguments: {'userName': userName},
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: {'userName': userName, 'userCategory': userCategory},
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),

      /// AppBar (Custom Status Style)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkGreen,
        toolbarHeight: 50,
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '9:41 AM',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                'PlateShare',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text('100%', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Back Button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Center(
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Center(
                      child: Text(
                        'Sign in to continue',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 40),

                    _buildInputField(
                      label: 'Email or Phone',
                      hint: 'Enter your email or phone',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      isPassword: true,
                    ),

                    const SizedBox(height: 20),

                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _performLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgotPassword');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
