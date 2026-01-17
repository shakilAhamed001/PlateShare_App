import 'package:flutter/material.dart';

class VolunteerTasksPage extends StatelessWidget {
  const VolunteerTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Task 1'),
            subtitle: const Text('Description of Task 1'),
            onTap: () {
              // Handle task 1 action
            },
          ),
          ListTile(
            title: const Text('Task 2'),
            subtitle: const Text('Description of Task 2'),
            onTap: () {
              // Handle task 2 action
            },
          ),
          // Add more tasks as needed
        ],
      ),
    );
  }
}
