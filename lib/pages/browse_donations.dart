import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';
import 'donation_detail.dart';

class BrowseDonationsPage extends StatefulWidget {
  const BrowseDonationsPage({super.key});

  @override
  State<BrowseDonationsPage> createState() => _BrowseDonationsPageState();
}

class _BrowseDonationsPageState extends State<BrowseDonationsPage> {
  List<Donation> availableDonations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    try {
      // availableDonations = await DonationService.getAvailableDonations();
      availableDonations = []; // Temporary empty list
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
        title: const Text('Available Donations'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableDonations.isEmpty
          ? const Center(
              child: Text(
                'No available donations at the moment.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: availableDonations.length,
              itemBuilder: (context, index) {
                final donation = availableDonations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading:
                        donation.imagePaths != null &&
                            donation.imagePaths!.isNotEmpty
                        ? Image.network(
                            donation.imagePaths!.first,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image, size: 50),
                          )
                        : const Icon(
                            Icons.fastfood,
                            size: 50,
                            color: Colors.green,
                          ),
                    title: Text(donation.name),
                    subtitle: Text(
                      '${donation.quantity} - ${donation.address}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DonationDetailPage(donation: donation),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
