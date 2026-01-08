import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/approve_requests.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Panel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              icon: Icons.people,
              title: 'Manage Users',
              subtitle: 'View and manage all users',
              onTap: () {
                // Navigate to user management
              },
            ),
            _buildActionCard(
              icon: Icons.inventory,
              title: 'Manage Donations',
              subtitle: 'Oversee food donations',
              onTap: () {
                // Navigate to donations management
              },
            ),
            _buildActionCard(
              icon: Icons.assignment_turned_in,
              title: 'Approve Requests',
              subtitle: 'Review and approve food requests',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApproveRequestsPage()),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.settings,
              title: 'System Settings',
              subtitle: 'Configure app settings',
              onTap: () {
                // Navigate to settings
              },
            ),
            _buildActionCard(
              icon: Icons.help,
              title: 'Support & Help',
              subtitle: 'Manage support requests',
              onTap: () {
                // Navigate to support
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
        leading: Icon(icon, size: 40, color: Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
