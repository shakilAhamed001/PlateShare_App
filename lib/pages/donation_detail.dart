import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/donation_model.dart';

class DonationDetailPage extends StatelessWidget {
  final Donation donation;

  const DonationDetailPage({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (donation.imagePaths != null && donation.imagePaths!.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: donation.imagePaths!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        donation.imagePaths![index],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, size: 200),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Food Name: ${donation.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Quantity: ${donation.quantity}'),
            const SizedBox(height: 8),
            Text('Source: ${donation.source}'),
            const SizedBox(height: 8),
            Text('Address: ${donation.address}'),
            const SizedBox(height: 8),
            Text('Phone: ${donation.phone}'),
            const SizedBox(height: 8),
            Text('NGO: ${donation.ngo}'),
            const SizedBox(height: 8),
            Text('Status: ${donation.status}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement request food functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request functionality to be implemented'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Request This Donation'),
            ),
          ],
        ),
      ),
    );
  }
}
