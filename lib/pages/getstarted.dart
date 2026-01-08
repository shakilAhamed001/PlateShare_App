import 'package:flutter/material.dart';

// --- Shared Constants ---
const Color primaryGreen = Color(0xFF4CAF50);
const Color darkGreen = Color(0xFF388E3C);
const Color cardGreen = Color(0xFF66BB6A);

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 40.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41 AM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Emojis rely on system font fallback
          Text('🍎', style: TextStyle(fontSize: 80)),
          SizedBox(height: 10),
          Text(
            'PlateShare',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Connecting Communities Through Food',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String description,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Emojis rely on system font fallback
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkGreen, primaryGreen, darkGreen],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          // SOLUTION: Use SingleChildScrollView to prevent overflow
          child: SingleChildScrollView(
            primary: true,
            physics: const ClampingScrollPhysics(),

            child: Column(
              children: [
                _buildHeader(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      _buildFeatureCard(
                        icon: '🍎',
                        title: 'Share & Donate',
                        description:
                            'Help reduce food waste by sharing surplus food with those in need',
                        cardColor: cardGreen,
                      ),
                      const SizedBox(height: 20),

                      _buildFeatureCard(
                        icon: '🛒',
                        title: 'Smart Shopping',
                        description:
                            'Buy discounted quality food from local restaurants and stores',
                        cardColor: cardGreen,
                      ),
                      const SizedBox(height: 20),

                      _buildFeatureCard(
                        icon: '❤️',
                        title: 'Volunteer',
                        description:
                            'Join our community of helpers making a difference',
                        cardColor: cardGreen,
                      ),
                      const SizedBox(height: 50),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
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
