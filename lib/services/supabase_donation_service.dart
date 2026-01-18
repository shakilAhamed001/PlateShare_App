import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDonationService {
  static final _supabase = Supabase.instance.client;

  static Future<void> addDonation({
    required String donorId,
    required String item,
    required String quantity,
    required String status,
  }) async {
    await _supabase.from('donation_history').insert({
      'donor_id': donorId,
      'item': item,
      'quantity': quantity,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getDonationsByDonor(String donorId) async {
    final response = await _supabase
        .from('donation_history')
        .select()
        .eq('donor_id', donorId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> updateDonationStatus(int id, String status) async {
    await _supabase
        .from('donation_history')
        .update({'status': status})
        .eq('id', id);
  }
}