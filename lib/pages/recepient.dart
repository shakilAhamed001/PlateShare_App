import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/request_food.dart';

class RecepientPage extends StatefulWidget {
  const RecepientPage({super.key});

  @override
  State<RecepientPage> createState() => _RecepientPageState();
}

class _RecepientPageState extends State<RecepientPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipient Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Recipient!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              icon: Icons.food_bank,
              title: 'Request Food',
              subtitle: 'Submit a food request',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestFoodPage(),
                  ),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.search,
              title: 'Browse Available Food',
              subtitle: 'Find food near you',
              onTap: () {
                // Navigate to browse food page
              },
            ),
            _buildActionCard(
              icon: Icons.location_on,
              title: 'Find Nearby Donations',
              subtitle: 'Locate food donations',
              onTap: () {
                // Navigate to map or list
              },
            ),
            _buildActionCard(
              icon: Icons.history,
              title: 'My Requests',
              subtitle: 'View request history',
              onTap: () {
                // Navigate to requests history
              },
            ),
            _buildActionCard(
              icon: Icons.star,
              title: 'Favorites',
              subtitle: 'Saved food items',
              onTap: () {
                // Navigate to favorites
              },
            ),
            _buildActionCard(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Updates on requests',
              onTap: () {
                // Navigate to notifications
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
