import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/volunteer_model.dart';
import 'package:flutter_application_2/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VolunteerTasksPage extends StatefulWidget {
  const VolunteerTasksPage({super.key});

  @override
  State<VolunteerTasksPage> createState() => _VolunteerTasksPageState();
}

class _VolunteerTasksPageState extends State<VolunteerTasksPage> {
  List<VolunteerTask> tasks = [];
  bool isLoading = true;
  String volunteerId = '';

  @override
  void initState() {
    super.initState();
    _initVolunteer();
  }

  Future<void> _initVolunteer() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        setState(() {
          volunteerId = user.id;
        });
        await _loadTasks();
      }
    } catch (e) {
      print('Error initializing volunteer: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadTasks() async {
    try {
      print('Loading tasks for volunteer: $volunteerId');
      tasks = await SupabaseService.getTasksForVolunteer(volunteerId);
      print('Loaded ${tasks.length} tasks');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await SupabaseService.updateTaskStatus(taskId, newStatus);
      await _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _getStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (status) {
      case 'assigned':
        bgColor = Colors.blue;
        break;
      case 'in_progress':
        bgColor = Colors.orange;
        break;
      case 'completed':
        bgColor = Colors.green;
        break;
      case 'cancelled':
        bgColor = Colors.grey;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tasks assigned yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                VolunteerTask task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Donation ID: ${task.donationId}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Assigned: ${task.assignedAt.toString().split('.')[0]}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _getStatusBadge(task.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (task.notes != null && task.notes!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(task.notes!),
                              const SizedBox(height: 12),
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (task.status == 'assigned')
                              ElevatedButton.icon(
                                onPressed: () {
                                  _updateTaskStatus(task.id, 'in_progress');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start'),
                              ),
                            if (task.status == 'in_progress')
                              ElevatedButton.icon(
                                onPressed: () {
                                  _updateTaskStatus(task.id, 'completed');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text('Complete'),
                              ),
                            if (task.status != 'completed' &&
                                task.status != 'cancelled')
                              const SizedBox(width: 8),
                            if (task.status != 'completed' &&
                                task.status != 'cancelled')
                              ElevatedButton.icon(
                                onPressed: () {
                                  _updateTaskStatus(task.id, 'cancelled');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text('Cancel'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
