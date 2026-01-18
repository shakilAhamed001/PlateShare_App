import 'package:flutter/material.dart';

class HelpRequestsPage extends StatefulWidget {
  const HelpRequestsPage({super.key});

  @override
  State<HelpRequestsPage> createState() => _HelpRequestsPageState();
}

class _HelpRequestsPageState extends State<HelpRequestsPage> {
  final List<Map<String, dynamic>> helpRequests = [
    {
      'id': 1,
      'title': 'Need delivery assistance',
      'description': 'Help needed for food delivery to elderly residents',
      'priority': 'High',
      'status': 'Open',
      'date': '2024-01-18',
    },
    {
      'id': 2,
      'title': 'Sorting donations',
      'description': 'Volunteers needed to sort and organize donations',
      'priority': 'Medium',
      'status': 'Open',
      'date': '2024-01-17',
    },
    {
      'id': 3,
      'title': 'Event setup',
      'description': 'Help setting up for upcoming charity event',
      'priority': 'Medium',
      'status': 'Open',
      'date': '2024-01-16',
    },
  ];

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Requests'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support Requests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...helpRequests.map((request) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: _getPriorityColor(request['priority']),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request['title'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  request['description'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(request['priority']).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  request['priority'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getPriorityColor(request['priority']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(request['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request accepted!')),
                              );
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Accept'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
