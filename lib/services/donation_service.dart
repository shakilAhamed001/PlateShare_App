import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/models/volunteer_model.dart';
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
    try {
      print('=== Approving request: $requestId ===');

      // First, try to get the full request data BEFORE updating
      print('Fetching request details...');
      final req = await SupabaseService.getRequestById(requestId);

      if (req == null) {
        print('ERROR: Could not fetch request data for ID: $requestId');
        throw Exception('Request not found or cannot be accessed');
      }

      print(
        'Request found - Recipient: ${req.recipientId}, Donation: ${req.donationId}',
      );

      // Update request status
      print('Updating request status to approved...');
      await SupabaseService.updateRequestStatus(requestId, 'approved');

      // Update donation status to approved/allocated
      print('Updating donation status to approved...');
      await SupabaseService.updateDonationStatus(req.donationId, 'approved');

      // Notify the recipient (non-critical, continue even if it fails)
      print('Creating notification...');
      try {
        await SupabaseService.createNotification(
          req.recipientId,
          'Your request for donation ${req.donationId} has been approved.',
          req.donationId,
        );
        print('✓ Notification created');
      } catch (notifError) {
        print('⚠ Warning: Could not create notification - $notifError');
        // Don't fail the whole approval just because notification failed
      }

      print('✓ Request $requestId approved successfully');
    } catch (e) {
      print('ERROR approving request: $e');
      rethrow;
    }
  }

  static Future<void> rejectRequest(String requestId) async {
    try {
      print('=== Rejecting request: $requestId ===');

      // First, try to get the full request data BEFORE updating
      print('Fetching request details...');
      final req = await SupabaseService.getRequestById(requestId);

      if (req == null) {
        print('ERROR: Could not fetch request data for ID: $requestId');
        throw Exception('Request not found or cannot be accessed');
      }

      print(
        'Request found - Recipient: ${req.recipientId}, Donation: ${req.donationId}',
      );

      // Update request status
      print('Updating request status to rejected...');
      await SupabaseService.updateRequestStatus(requestId, 'rejected');

      // Update donation status back to available
      print('Updating donation status to available...');
      await SupabaseService.updateDonationStatus(req.donationId, 'available');

      // Notify the recipient (non-critical, continue even if it fails)
      print('Creating rejection notification...');
      try {
        await SupabaseService.createNotification(
          req.recipientId,
          'Your request for donation ${req.donationId} has been rejected.',
          req.donationId,
        );
        print('✓ Notification created');
      } catch (notifError) {
        print('⚠ Warning: Could not create notification - $notifError');
        // Don't fail the whole rejection just because notification failed
      }

      print('✓ Request $requestId rejected successfully');
    } catch (e) {
      print('ERROR rejecting request: $e');
      rethrow;
    }
  }

  static Future<List<FoodRequest>> getRequestsForRecipient(
    String recipientId,
  ) async {
    return await SupabaseService.getUserRequests();
  }

  // Volunteer assignment methods
  static Future<List<Volunteer>> getAvailableVolunteers() async {
    return await SupabaseService.getAvailableVolunteers();
  }

  static Future<void> assignVolunteerToTask(
    String donationId,
    String volunteerId,
  ) async {
    return await SupabaseService.assignTaskToVolunteer(donationId, volunteerId);
  }

  static Future<void> approveRequestWithVolunteer(
    String requestId,
    String volunteerId,
  ) async {
    try {
      print('=== Approving request with volunteer assignment ===');

      // First, try to get the full request data BEFORE updating
      print('Fetching request details...');
      final req = await SupabaseService.getRequestById(requestId);

      if (req == null) {
        print('ERROR: Could not fetch request data for ID: $requestId');
        throw Exception('Request not found or cannot be accessed');
      }

      print(
        'Request found - Recipient: ${req.recipientId}, Donation: ${req.donationId}',
      );

      // Update request status
      print('Updating request status to approved...');
      await SupabaseService.updateRequestStatus(requestId, 'approved');

      // Update donation status to approved/allocated
      print('Updating donation status to approved...');
      await SupabaseService.updateDonationStatus(req.donationId, 'approved');

      // Assign volunteer to the donation task
      print(
        'Assigning volunteer $volunteerId to donation ${req.donationId}...',
      );
      await SupabaseService.assignTaskToVolunteer(req.donationId, volunteerId);

      // Notify the recipient (non-critical, continue even if it fails)
      print('Creating notification...');
      try {
        await SupabaseService.createNotification(
          req.recipientId,
          'Your request for donation ${req.donationId} has been approved. A volunteer has been assigned to help with delivery.',
          req.donationId,
        );
        print('✓ Notification created');
      } catch (notifError) {
        print('⚠ Warning: Could not create notification - $notifError');
      }

      print(
        '✓ Request $requestId approved and volunteer assigned successfully',
      );
    } catch (e) {
      print('ERROR approving request with volunteer: $e');
      rethrow;
    }
  }
}
