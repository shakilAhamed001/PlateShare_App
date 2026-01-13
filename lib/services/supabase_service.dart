import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_2/models/donation_model.dart';

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
    await _supabase.from('food_requests').insert({
      'donation_id': donationId,
      'recipient_id': _supabase.auth.currentUser!.id,
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
    final response = await _supabase
        .from('food_requests')
        .select(
          '*, donations(name, source, quantity, donors(name, phone, address)), recipients(name, phone, address)',
        )
        .eq('status', 'pending');

    return response.map((data) => FoodRequest.fromMap(data)).toList();
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
}
