import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/supabase_service.dart';

class DonationService {
  static Future<void> addDonation(Donation donation) async {
    await SupabaseService.createDonation(donation);
  }

  static Future<List<Donation>> getAvailableDonations() async {
    return await SupabaseService.getAvailableDonations();
  }

  static Future<void> addRequest(FoodRequest request) async {
    await SupabaseService.createFoodRequest(request.donationId);
    // Update donation status to requested
    await SupabaseService.updateDonationStatus(request.donationId, 'requested');
  }

  static Future<List<FoodRequest>> getPendingRequests() async {
    return await SupabaseService.getPendingRequests();
  }

  static Future<void> approveRequest(String requestId) async {
    await SupabaseService.updateRequestStatus(requestId, 'approved');
    // Fetch the request to get recipient and donation ids
    final req = await SupabaseService.getRequestById(requestId);
    if (req != null) {
      // Notify the recipient
      await SupabaseService.createNotification(
        req.recipientId,
        'Your request for donation ${req.donationId} has been approved.',
        req.donationId,
      );
      // Update donation status to approved/allocated
      await SupabaseService.updateDonationStatus(req.donationId, 'approved');
    }
  }

  static Future<void> rejectRequest(String requestId) async {
    await SupabaseService.updateRequestStatus(requestId, 'rejected');
    final req = await SupabaseService.getRequestById(requestId);
    if (req != null) {
      await SupabaseService.createNotification(
        req.recipientId,
        'Your request for donation ${req.donationId} has been rejected.',
        req.donationId,
      );
      await SupabaseService.updateDonationStatus(req.donationId, 'available');
    }
  }

  static Future<List<FoodRequest>> getRequestsForRecipient(
    String recipientId,
  ) async {
    return await SupabaseService.getUserRequests();
  }
}
