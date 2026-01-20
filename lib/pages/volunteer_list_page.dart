import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/local_volunteer_service.dart';

class VolunteerListPage extends StatefulWidget {
  const VolunteerListPage({super.key});

  @override
  State<VolunteerListPage> createState() => _VolunteerListPageState();
}

class _VolunteerListPageState extends State<VolunteerListPage> {
  List<Map<String, dynamic>> volunteers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }

  Future<void> _loadVolunteers() async {
    try {
      final volunteerList = await LocalVolunteerService.getAllVolunteers();
      setState(() {
        volunteers = volunteerList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer List'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : volunteers.isEmpty
              ? const Center(child: Text('No volunteers found'))
              : ListView.builder(
                  itemCount: volunteers.length,
                  itemBuilder: (context, index) {
                    final volunteer = volunteers[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            volunteer['name']?.substring(0, 1).toUpperCase() ?? 'V',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(volunteer['name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone: ${volunteer['phone'] ?? 'N/A'}'),
                            Text('Area: ${volunteer['address'] ?? 'N/A'}'),
                            Text('Status: ${volunteer['status'] ?? 'Available'}'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: volunteer['status'] == 'Available' 
                                ? Colors.green 
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            volunteer['status'] ?? 'Available',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}