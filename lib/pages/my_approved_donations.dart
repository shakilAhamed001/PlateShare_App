import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/supabase_service.dart';

class MyApprovedDonationsPage extends StatefulWidget {
  const MyApprovedDonationsPage({super.key});

  @override
  State<MyApprovedDonationsPage> createState() =>
      _MyApprovedDonationsPageState();
}

class _MyApprovedDonationsPageState extends State<MyApprovedDonationsPage> {
  List<Map<String, dynamic>> approvedDonations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovedDonations();
  }

  Future<void> _loadApprovedDonations() async {
    try {
      final donations =
          await SupabaseService.getApprovedDonationsForRecipient();
      setState(() {
        approvedDonations = donations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading donations: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Approved Donations'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : approvedDonations.isEmpty
          ? const Center(
              child: Text(
                'No approved donations yet.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: approvedDonations.length,
              itemBuilder: (context, index) {
                final request = approvedDonations[index];
                final donation = request['donations'] as Map<String, dynamic>?;
                final donor = donation?['donors'] as Map<String, dynamic>?;

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
                                    donation?['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Food: ${donation?['source'] ?? 'N/A'}',
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
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Approved',
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
                            const Icon(
                              Icons.local_shipping,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Quantity: ${donation?['quantity'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Location: ${donation?['address'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Donor: ${donor?['name'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Phone: ${donor?['phone'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Show contact details
                            _showDonorContactDialog(
                              donor?['name'] ?? 'Donor',
                              donor?['phone'] ?? 'N/A',
                              donor?['address'] ?? 'N/A',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Contact Donor'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDonorContactDialog(String name, String phone, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Donor Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name'),
            const SizedBox(height: 8),
            Text('Phone: $phone'),
            const SizedBox(height: 8),
            Text('Address: $address'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
