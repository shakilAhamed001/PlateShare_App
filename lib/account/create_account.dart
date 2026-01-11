import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/donation.dart';
import '../pages/recepient.dart';
import '../pages/volunteer.dart';
import '../pages/seller.dart';
import '../pages/admin.dart';

/// A modern, attractive Create Account screen template
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePass = true;
  String _selectedCategory = 'Donor';

  late final AnimationController _appearController;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appearController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _appearController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // More permissive regex that allows longer TLDs and modern addresses
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email (e.g. name@example.com)';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number required';
    }
    if (value.trim().length < 7) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _register() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _loading = true);

    try {
      final supabase = Supabase.instance.client;
      final email = _emailCtrl.text.trim().toLowerCase();
      final password = _passCtrl.text.trim();

      // Client-side sanity check (prevents common 400 from Supabase)
      final emailCheck = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailCheck.hasMatch(email)) {
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid email address. Please use a valid email like name@example.com',
            ),
          ),
        );
        return;
      }

      // Reject extremely short local parts which some Auth servers validate stricter
      final parts = email.split('@');
      if (parts.isEmpty || parts[0].length < 3) {
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email local part is too short — use at least 3 characters before the @',
            ),
          ),
        );
        return;
      }

      // Sign up with Supabase and catch any thrown errors
      AuthResponse? signUpRes;
      try {
        signUpRes = await supabase.auth.signUp(
          email: email,
          password: password,
        );
      } catch (e) {
        // Map common Supabase messages to friendly text
        final err = e.toString().toLowerCase();
        var userMsg = 'Signup failed: ${e.toString()}';
        if (err.contains('email_address_invalid') ||
            (err.contains('invalid') && err.contains('email')) ||
            err.contains('email address')) {
          userMsg =
              'Invalid email address. Try a different email (e.g., use at least 3 characters before the @) or check your Supabase email settings.';
        } else if (err.contains('duplicate') ||
            err.contains('already exists')) {
          userMsg =
              'This email is already registered. Try logging in or use a different email.';
        }

        // ignore: avoid_print
        print('Supabase signup error: $e');
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userMsg)));
        return;
      }

      final user = signUpRes?.user ?? supabase.auth.currentUser;

      // Always save the chosen display name and category locally —
      // we'll create the server-side profile at first successful login instead.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userCategory', _selectedCategory);
      await prefs.setString('userName', _nameCtrl.text.trim());

      setState(() => _loading = false);

      if (!mounted) return;

      // Inform the user and send them to the login screen to complete sign-in.
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Success'),
            ],
          ),
          content: const Text('Account created successfully! Please sign in.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _socialButton(IconData icon, Color color, String label) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLarge = width > 600;

    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _appearController,
                      curve: Curves.easeOut,
                    ),
                    child: Column(
                      children: const [
                        SizedBox(height: 12),
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.cake,
                            size: 40,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Create Your Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Join the community to share food & reduce waste',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isLarge ? 540 : double.infinity,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 22,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _nameCtrl,
                                  validator: _validateName,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.person),
                                    labelText: 'Full name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _emailCtrl,
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                    labelText: 'Email address',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _phoneCtrl,
                                  validator: _validatePhone,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.phone_android_outlined,
                                    ),
                                    labelText: 'Phone',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscurePass,
                                  validator: _validatePassword,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    labelText: 'Password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePass
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePass = !_obscurePass;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.category),
                                    labelText: 'Category',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  items:
                                      const [
                                            'Donor',
                                            'Recipient',
                                            'Volunteer',
                                            'Seller',
                                          ]
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      _selectedCategory = v!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _loading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
