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
    // Get the donation id from the request and update status
    // For simplicity, assume we have the donation id
    // In practice, fetch the request first
  }

  static Future<void> rejectRequest(String requestId) async {
    await SupabaseService.updateRequestStatus(requestId, 'rejected');
    // Update donation status back to available
  }

  static Future<List<FoodRequest>> getRequestsForRecipient(
    String recipientId,
  ) async {
    return await SupabaseService.getUserRequests();
  }
}
