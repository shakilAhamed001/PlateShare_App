import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestFoodPage extends StatefulWidget {
  const RequestFoodPage({super.key});

  @override
  State<RequestFoodPage> createState() => _RequestFoodPageState();
}

class _RequestFoodPageState extends State<RequestFoodPage> {
  late String recipientId;

  @override
  void initState() {
    super.initState();
    _loadRecipientId();
  }

  Future<void> _loadRecipientId() async {
    final prefs = await SharedPreferences.getInstance();
    recipientId = prefs.getString('userName') ?? 'Unknown';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Donation> availableDonations = DonationService.getAvailableDonations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Food'),
        backgroundColor: Colors.green,
      ),
      body: availableDonations.isEmpty
          ? const Center(child: Text('No available donations at the moment.'))
          : ListView.builder(
              itemCount: availableDonations.length,
              itemBuilder: (context, index) {
                Donation donation = availableDonations[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Food: ${donation.source}'),
                    subtitle: Text(
                      'Quantity: ${donation.quantity}\nLocation: ${donation.address}\nDonor: ${donation.donorId}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _requestFood(donation);
                      },
                      child: const Text('Request'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _requestFood(Donation donation) {
    FoodRequest request = FoodRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      donationId: donation.id,
      recipientId: recipientId,
    );
    DonationService.addRequest(request);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Food request submitted!')));
    setState(() {});
  }
}
