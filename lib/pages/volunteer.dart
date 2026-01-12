import 'package:flutter/material.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
  //demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Volunteer Panel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              icon: Icons.volunteer_activism,
              title: 'Manage Donations',
              subtitle: 'Help donors with their contributions',
              iconColor: Colors.green,
              onTap: () {
                // Navigate to manage donations
                Navigator.pushNamed(context, '/donation');
              },
            ),
            _buildActionCard(
              icon: Icons.people,
              title: 'Coordinate Recipients',
              subtitle: 'Assist recipients in need',
              iconColor: Colors.blue,
              onTap: () {
                // Navigate to coordinate recipients
                Navigator.pushNamed(context, '/recipient');
              },
            ),
            _buildActionCard(
              icon: Icons.report,
              title: 'View Reports',
              subtitle: 'Check volunteering statistics',
              iconColor: Colors.orange,
              onTap: () {
                // Navigate to reports
              },
            ),
            _buildActionCard(
              icon: Icons.help,
              title: 'Help Requests',
              subtitle: 'Respond to support requests',
              iconColor: Colors.purple,
              onTap: () {
                // Navigate to help requests
              },
            ),
          ],
        ),
      ),
    );
  }
}
