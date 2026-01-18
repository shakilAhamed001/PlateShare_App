import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/models/volunteer_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';
import 'package:flutter_application_2/services/local_request_service.dart';
import 'package:flutter_application_2/services/supabase_service.dart';

class ApproveRequestsPage extends StatefulWidget {
  const ApproveRequestsPage({super.key});

  @override
  State<ApproveRequestsPage> createState() => _ApproveRequestsPageState();
}

class _ApproveRequestsPageState extends State<ApproveRequestsPage> {
  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      print('Loading pending requests...');
      pendingRequests = LocalRequestService.getPendingRequests();
      print('Loaded ${pendingRequests.length} requests');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading requests: $e');
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

  Future<void> _showVolunteerSelectionDialog(FoodRequest request) async {
    List<Volunteer> volunteers = [];
    bool loadingVolunteers = true;

    try {
      // volunteers = await DonationService.getAvailableVolunteers();
      volunteers = []; // Temporary empty list
      loadingVolunteers = false;
    } catch (e) {
      print('Error loading volunteers: $e');
      loadingVolunteers = false;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Assign Volunteer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a volunteer to assign this donation delivery task:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                if (loadingVolunteers)
                  const Center(child: CircularProgressIndicator())
                else if (volunteers.isEmpty)
                  const Center(
                    child: Text(
                      'No volunteers available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: volunteers.length,
                      itemBuilder: (context, index) {
                        Volunteer volunteer = volunteers[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.person_outline,
                            color: Colors.blue,
                          ),
                          title: Text(volunteer.name),
                          subtitle: Text(volunteer.phone),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            try {
                              // await DonationService.approveRequestWithVolunteer(
                              //   request.id,
                              //   volunteer.id,
                              // );
                              await _loadRequests();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Request approved! Volunteer ${volunteer.name} assigned.',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              print('Error approving with volunteer: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Requests'),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingRequests.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No pending requests.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final request = pendingRequests[index];
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
                                    'Food: ${request['foodItem']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Recipient: ${request['recipientId']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Pending',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Quantity: ${request['quantity']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Location: ${request['location']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Donor: ${request['donorId']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                LocalRequestService.updateRequestStatus(
                                  request['id'],
                                  'Approved',
                                );
                                await _loadRequests();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Request approved!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              icon: const Icon(Icons.check),
                              label: const Text('Approve'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                LocalRequestService.updateRequestStatus(
                                  request['id'],
                                  'Rejected',
                                );
                                await _loadRequests();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Request rejected!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
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
