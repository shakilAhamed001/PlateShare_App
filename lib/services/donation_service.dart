import 'package:flutter_application_2/models/donation_model.dart';

class DonationService {
  static List<Donation> donations = [];
  static List<FoodRequest> requests = [];

  static void addDonation(Donation donation) {
    donations.add(donation);
  }

  static List<Donation> getAvailableDonations() {
    return donations.where((d) => d.status == 'available').toList();
  }

  static void addRequest(FoodRequest request) {
    requests.add(request);
    // Update donation status to requested
    var donation = donations.firstWhere((d) => d.id == request.donationId);
    donation.status = 'requested';
  }

  static List<FoodRequest> getPendingRequests() {
    return requests.where((r) => r.status == 'pending').toList();
  }

  static void approveRequest(String requestId) {
    var request = requests.firstWhere((r) => r.id == requestId);
    request.status = 'approved';
    var donation = donations.firstWhere((d) => d.id == request.donationId);
    donation.status = 'approved';
  }

  static void rejectRequest(String requestId) {
    var request = requests.firstWhere((r) => r.id == requestId);
    request.status = 'rejected';
    var donation = donations.firstWhere((d) => d.id == request.donationId);
    donation.status = 'available'; // back to available
  }

  static List<FoodRequest> getRequestsForRecipient(String recipientId) {
    return requests.where((r) => r.recipientId == recipientId).toList();
  }
}
