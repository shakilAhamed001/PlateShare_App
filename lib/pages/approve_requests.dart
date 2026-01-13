import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';
import 'package:flutter_application_2/services/supabase_service.dart';

class ApproveRequestsPage extends StatefulWidget {
  const ApproveRequestsPage({super.key});

  @override
  State<ApproveRequestsPage> createState() => _ApproveRequestsPageState();
}

class _ApproveRequestsPageState extends State<ApproveRequestsPage> {
  List<FoodRequest> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      pendingRequests = await DonationService.getPendingRequests();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
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
          ? const Center(child: Text('No pending requests.'))
          : ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                FoodRequest request = pendingRequests[index];
                return FutureBuilder<Donation?>(
                  future: SupabaseService.getDonationById(request.donationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(title: Text('Loading...')),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(title: Text('Error loading donation')),
                      );
                    } else {
                      Donation donation = snapshot.data!;
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Request by: ${request.recipientId}'),
                          subtitle: Text(
                            'Food: ${donation.source}\nQuantity: ${donation.quantity}\nLocation: ${donation.address}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await DonationService.approveRequest(
                                    request.id,
                                  );
                                  await _loadRequests();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Request approved!'),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Approve'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  await DonationService.rejectRequest(
                                    request.id,
                                  );
                                  await _loadRequests();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Request rejected!'),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
