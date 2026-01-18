import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/models/notification_model.dart';
import 'package:flutter_application_2/models/volunteer_model.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Donor operations
  static Future<void> createDonor(
    String name,
    String phone,
    String address,
    String? email,
  ) async {
    await _supabase.from('donors').insert({
      'id': _supabase.auth.currentUser!.id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
    });
  }

  // Donation operations
  static Future<void> createDonation(Donation donation) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('No authenticated user');

    // Ensure a donor row exists for the current user. If it already exists,
    // ignore the duplicate-key error and continue to insert the donation.
    try {
      await _supabase.from('donors').insert({
        'id': uid,
        'name': donation.name,
        'phone': donation.phone,
        'address': donation.address,
        'email': _supabase.auth.currentUser!.email,
      });
    } catch (e) {
      final msg = e.toString();
      if (!msg.contains('23505') && !msg.toLowerCase().contains('duplicate')) {
        rethrow;
      }
    }

    await _supabase.from('donations').insert({
      'name': donation.name,
      'phone': donation.phone,
      'address': donation.address,
      'source': donation.source,
      'quantity': donation.quantity,
      'ngo': donation.ngo,
      'image_urls': donation.imagePaths,
      'status': donation.status,
      'donor_id': uid,
    });
  }

  static Future<List<Donation>> getAvailableDonations() async {
    final response = await _supabase
        .from('donations')
        .select('*, donors(name)')
        .eq('status', 'available');

    return response.map((data) => Donation.fromMap(data)).toList();
  }

  static Future<List<Donation>> getDonationsByDonor(String donorId) async {
    final response = await _supabase
        .from('donations')
        .select('*, donors(name, phone, address)')
        .eq('donor_id', donorId);

    return response.map((data) => Donation.fromMap(data)).toList();
  }

  static Future<Donation?> getDonationById(String id) async {
    final response = await _supabase
        .from('donations')
        .select('*, donors(name, phone, address)')
        .eq('id', id)
        .single();

    return Donation.fromMap(response);
  }

  // Recipient operations
  static Future<void> createRecipient(
    String name,
    String phone,
    String address,
    String? email,
  ) async {
    await _supabase.from('recipients').insert({
      'id': _supabase.auth.currentUser!.id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
    });
  }

  // Food Request operations
  static Future<void> createFoodRequest(String donationId) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('No authenticated user');

    // Ensure a recipient row exists for the current user. If it already
    // exists, ignore the duplicate-key error and continue to insert the request.
    try {
      await _supabase.from('recipients').insert({
        'id': uid,
        'name': '',
        'phone': '',
        'address': '',
        'email': _supabase.auth.currentUser!.email,
      });
    } catch (e) {
      final msg = e.toString();
      if (!msg.contains('23505') && !msg.toLowerCase().contains('duplicate')) {
        rethrow;
      }
    }

    await _supabase.from('food_requests').insert({
      'donation_id': donationId,
      'recipient_id': uid,
      'status': 'pending',
      'request_time': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<FoodRequest>> getUserRequests() async {
    final response = await _supabase
        .from('food_requests')
        .select(
          '*, donations(name, source, quantity, donors(name)), recipients(name)',
        )
        .eq('recipient_id', _supabase.auth.currentUser!.id);

    return response.map((data) => FoodRequest.fromMap(data)).toList();
  }

  static Future<List<FoodRequest>> getPendingRequests() async {
    try {
      print('Attempting to fetch pending requests...');
      // Fetch all pending requests without RLS restrictions
      // Using direct query
      final response = await _supabase
          .from('food_requests')
          .select('id, donation_id, recipient_id, status, request_time')
          .eq('status', 'pending')
          .order('request_time', ascending: false);

      print('Response: $response');
      print('Response count: ${response.length}');

      final requests = response
          .map((data) => FoodRequest.fromMap(data))
          .toList();
      print('Parsed requests count: ${requests.length}');
      return requests;
    } catch (e) {
      print('Error fetching pending requests (attempt 1): $e');
      // If RLS blocks it, try fetching without order
      try {
        print('Attempting fallback query...');
        final response = await _supabase
            .from('food_requests')
            .select('id, donation_id, recipient_id, status, request_time')
            .eq('status', 'pending');
        print('Fallback response: $response');
        return response.map((data) => FoodRequest.fromMap(data)).toList();
      } catch (e2) {
        print('Second attempt failed: $e2');
        // Last resort: try to get ALL requests
        try {
          print('Attempting to fetch ALL requests...');
          final allRequests = await _supabase
              .from('food_requests')
              .select('id, donation_id, recipient_id, status, request_time');
          print('All requests response: $allRequests');
          return allRequests.map((data) => FoodRequest.fromMap(data)).toList();
        } catch (e3) {
          print('All attempts failed: $e3');
          return [];
        }
      }
    }
  }

  static Future<void> updateDonationStatus(
    String donationId,
    String status,
  ) async {
    await _supabase
        .from('donations')
        .update({'status': status})
        .eq('id', donationId);
  }

  static Future<void> updateRequestStatus(
    String requestId,
    String status,
  ) async {
    await _supabase
        .from('food_requests')
        .update({'status': status})
        .eq('id', requestId);
  }

  // Get single request
  static Future<FoodRequest?> getRequestById(String id) async {
    try {
      final response = await _supabase
          .from('food_requests')
          .select()
          .eq('id', id)
          .single();

      return FoodRequest.fromMap(response);
    } catch (e) {
      print('Error fetching request by ID: $e');
      // Return null instead of crashing
      return null;
    }
  }

  // Notification operations
  static Future<void> createNotification(
    String recipientId,
    String message,
    String donationId,
  ) async {
    await _supabase.from('notifications').insert({
      'recipient_id': recipientId,
      'message': message,
      'donation_id': donationId,
      'read': false,
    });
  }

  static Future<List<AppNotification>> getNotificationsForUser() async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('recipient_id', _supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);

    return response.map((data) => AppNotification.fromMap(data)).toList();
  }

  static Future<void> markNotificationRead(String id) async {
    await _supabase.from('notifications').update({'read': true}).eq('id', id);
  }

  // Get approved donations for a recipient
  static Future<List<Map<String, dynamic>>>
  getApprovedDonationsForRecipient() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('No authenticated user');

    final response = await _supabase
        .from('food_requests')
        .select(
          '*, donations(id, name, source, quantity, address, phone, donors(name, phone, address)), recipients(name)',
        )
        .eq('recipient_id', uid)
        .eq('status', 'approved');

    return response;
  }

  // Get all requests (with different statuses) for a recipient
  static Future<List<Map<String, dynamic>>>
  getRecipientRequestsWithStatus() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('No authenticated user');

    final response = await _supabase
        .from('food_requests')
        .select(
          '*, donations(id, name, source, quantity, address, phone, donors(name, phone, address)), recipients(name)',
        )
        .eq('recipient_id', uid)
        .order('request_time', ascending: false);

    return response;
  }

  // Volunteer operations
  static Future<List<Volunteer>> getAvailableVolunteers() async {
    try {
      final response = await _supabase
          .from('volunteers')
          .select('id, name, phone, email, status, created_at')
          .eq('status', 'active')
          .order('name', ascending: true);

      return response.map((data) => Volunteer.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching volunteers: $e');
      return [];
    }
  }

  static Future<void> createVolunteer(Volunteer volunteer) async {
    try {
      await _supabase.from('volunteers').insert(volunteer.toMap());
    } catch (e) {
      print('Error creating volunteer: $e');
      rethrow;
    }
  }

  // Volunteer Task operations
  static Future<void> assignTaskToVolunteer(
    String donationId,
    String volunteerId,
  ) async {
    try {
      final taskId = _generateId();
      await _supabase.from('volunteer_tasks').insert({
        'id': taskId,
        'donation_id': donationId,
        'volunteer_id': volunteerId,
        'status': 'assigned',
        'assigned_at': DateTime.now().toIso8601String(),
      });
      print('Task assigned: $taskId to volunteer: $volunteerId');
    } catch (e) {
      print('Error assigning task: $e');
      rethrow;
    }
  }

  static Future<List<VolunteerTask>> getTasksForVolunteer(
    String volunteerId,
  ) async {
    try {
      final response = await _supabase
          .from('volunteer_tasks')
          .select(
            '*, donations(id, name, source, quantity, address, phone, donors(name)), volunteers(name, phone)',
          )
          .eq('volunteer_id', volunteerId)
          .neq('status', 'cancelled')
          .order('assigned_at', ascending: false);

      return response.map((data) => VolunteerTask.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching volunteer tasks: $e');
      return [];
    }
  }

  static Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      final updateData = {'status': status};
      if (status == 'completed') {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }
      await _supabase
          .from('volunteer_tasks')
          .update(updateData)
          .eq('id', taskId);
      print('Task $taskId status updated to $status');
    } catch (e) {
      print('Error updating task status: $e');
      rethrow;
    }
  }

  // Helper method to generate unique IDs
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString();
  }
}
