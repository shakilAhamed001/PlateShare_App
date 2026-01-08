import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';

class ApproveRequestsPage extends StatefulWidget {
  const ApproveRequestsPage({super.key});

  @override
  State<ApproveRequestsPage> createState() => _ApproveRequestsPageState();
}

class _ApproveRequestsPageState extends State<ApproveRequestsPage> {
  @override
  Widget build(BuildContext context) {
    List<FoodRequest> pendingRequests = DonationService.getPendingRequests();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Requests'),
        backgroundColor: Colors.red,
      ),
      body: pendingRequests.isEmpty
          ? const Center(child: Text('No pending requests.'))
          : ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                FoodRequest request = pendingRequests[index];
                Donation donation = DonationService.donations.firstWhere((d) => d.id == request.donationId);
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Request by: ${request.recipientId}'),
                    subtitle: Text('Food: ${donation.source}\nQuantity: ${donation.quantity}\nLocation: ${donation.address}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            DonationService.approveRequest(request.id);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request approved!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Approve'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            DonationService.rejectRequest(request.id);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request rejected!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Reject'),
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