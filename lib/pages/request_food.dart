import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';
import 'package:flutter_application_2/services/local_donation_service.dart';
import 'package:flutter_application_2/services/local_request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'donation_detail.dart';

class RequestFoodPage extends StatefulWidget {
  const RequestFoodPage({super.key});

  @override
  State<RequestFoodPage> createState() => _RequestFoodPageState();
}

class _RequestFoodPageState extends State<RequestFoodPage> {
  late String recipientId;
  List<Donation> availableDonations = [];
  bool isLoading = true;
  final Map<String, bool> _isSubmitting = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadRecipientId();
    await _loadDonations();
  }

  Future<void> _loadRecipientId() async {
    final prefs = await SharedPreferences.getInstance();
    recipientId = prefs.getString('userName') ?? 'Unknown';
  }

  Future<void> _loadDonations() async {
    try {
      // Get donations from local service
      final donations = LocalDonationService.getAllDonations();
      availableDonations = donations.map((d) => Donation(
        id: d['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: d['donor_name'] ?? 'Unknown',
        phone: d['phone'] ?? '',
        address: d['address'] ?? 'Unknown location',
        source: d['item'] ?? 'Food',
        quantity: d['quantity'] ?? '1',
        ngo: d['ngo'] ?? '',
        imagePaths: [],
        donorId: d['donor_id'] ?? 'Unknown',
        status: d['status'] ?? 'Available',
      )).where((d) => d.status == 'Pending' || d.status == 'Available').toList();
    } catch (e) {
      print('Error loading donations: $e');
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
        title: const Text('Request Food'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableDonations.isEmpty
          ? const Center(child: Text('No available donations at the moment.'))
          : ListView.builder(
              itemCount: availableDonations.length,
              itemBuilder: (context, index) {
                Donation donation = availableDonations[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Food: ${donation.source}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Quantity: ${donation.quantity}'),
                        Text('Location: ${donation.address}'),
                        Text('Donor: ${donation.donorId}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DonationDetailPage(donation: donation),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('See Details'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isSubmitting[donation.id] == true
                                  ? null
                                  : () async {
                                      await _requestFood(donation);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: _isSubmitting[donation.id] == true
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Request'),
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

  Future<void> _requestFood(Donation donation) async {
    setState(() => _isSubmitting[donation.id] = true);
    try {
      // Add request to local service for admin approval
      LocalRequestService.addRequest(
        donationId: donation.id,
        recipientId: recipientId,
        donorId: donation.donorId,
        foodItem: donation.source,
        quantity: donation.quantity,
        location: donation.address,
      );
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Food request submitted for admin approval!')));
      await _loadDonations(); // Reload donations
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit request: $e')));
    } finally {
      setState(() => _isSubmitting[donation.id] = false);
    }
  }
}
