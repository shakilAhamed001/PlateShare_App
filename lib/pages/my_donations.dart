import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDonationsPage extends StatefulWidget {
  const MyDonationsPage({super.key});

  @override
  State<MyDonationsPage> createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  late Future<List<Donation>> _donationsFuture;
  String? _currentDonorId;

  @override
  void initState() {
    super.initState();
    _loadDonorIdAndFetchDonations();
  }

  Future<void> _loadDonorIdAndFetchDonations() async {
    final prefs = await SharedPreferences.getInstance();
    _currentDonorId = prefs.getString('donor_id') ?? prefs.getString('phone_number') ?? 'default_donor';
    
    setState(() {
      // _donationsFuture = DonationService.fetchDonationsByDonor(_currentDonorId!);
      _donationsFuture = Future.value(<Donation>[]); // Temporary empty list
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.blue;
      case 'requested':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle_outline;
      case 'requested':
        return Icons.schedule;
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Donation>>(
        future: _donationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDonorIdAndFetchDonations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No donations yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Make a Donation'),
                  ),
                ],
              ),
            );
          }

          final donations = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Donations (${donations.length})',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...donations.map((donation) {
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
                                Icons.card_giftcard,
                                color: _getStatusColor(donation.status),
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      donation.source,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Quantity: ${donation.quantity}',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(donation.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(donation.status),
                                  size: 16,
                                  color: _getStatusColor(donation.status),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  donation.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getStatusColor(donation.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NGO: ${donation.ngo}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Location: ${donation.address}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (donation.imagePaths != null && donation.imagePaths!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ...donation.imagePaths!.take(3).map((imagePath) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: Image.network(
                                              imagePath,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(Icons.image_not_supported);
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    if (donation.imagePaths!.length > 3)
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '+${donation.imagePaths!.length - 3}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Donation Details'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Source: ${donation.source}'),
                                            const SizedBox(height: 8),
                                            Text('Quantity: ${donation.quantity}'),
                                            const SizedBox(height: 8),
                                            Text('NGO: ${donation.ngo}'),
                                            const SizedBox(height: 8),
                                            Text('Address: ${donation.address}'),
                                            const SizedBox(height: 8),
                                            Text('Status: ${donation.status}'),
                                            const SizedBox(height: 8),
                                            Text('Phone: ${donation.phone}'),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.info_outline, size: 18),
                                label: const Text('View Details'),
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
          );
        },
      ),
    );
  }
}
