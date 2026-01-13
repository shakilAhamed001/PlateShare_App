import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';
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
      availableDonations = await DonationService.getAvailableDonations();
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
                              onPressed: () async {
                                await _requestFood(donation);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Request'),
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
    FoodRequest request = FoodRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      donationId: donation.id,
      recipientId: recipientId,
    );
    await DonationService.addRequest(request);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Food request submitted!')));
    await _loadDonations(); // Reload donations
  }
}
