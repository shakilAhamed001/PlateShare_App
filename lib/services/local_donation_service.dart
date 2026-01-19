import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalDonationService {
  static final Map<String, List<Map<String, dynamic>>> _donationsByUser = {};
  static final List<Map<String, dynamic>> _allDonations = [];
  static bool _isLoaded = false;

  static Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    
    final prefs = await SharedPreferences.getInstance();
    final donationsJson = prefs.getString('donations');
    final requestsJson = prefs.getString('requests');
    
    if (donationsJson != null) {
      final List<dynamic> donationsList = json.decode(donationsJson);
      _allDonations.clear();
      _allDonations.addAll(donationsList.cast<Map<String, dynamic>>());
      
      // Rebuild user donations map
      _donationsByUser.clear();
      for (var donation in _allDonations) {
        final userId = donation['donor_id'];
        if (!_donationsByUser.containsKey(userId)) {
          _donationsByUser[userId] = [];
        }
        _donationsByUser[userId]!.add(donation);
      }
    }
    
    _isLoaded = true;
  }

  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('donations', json.encode(_allDonations));
  }

  static Future<void> addDonation(String userId, Map<String, dynamic> donation) async {
    await _loadFromStorage();
    
    if (!_donationsByUser.containsKey(userId)) {
      _donationsByUser[userId] = [];
    }
    // Add donor info to donation
    donation['donor_id'] = userId;
    donation['donor_name'] = userId;
    donation['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    donation['phone'] = '01700000000';
    donation['address'] = 'Dhaka, Bangladesh';
    donation['ngo'] = 'Local NGO';
    // Keep image URLs if they exist
    if (!donation.containsKey('imageUrls')) {
      donation['imageUrls'] = [];
    }
    
    _donationsByUser[userId]!.add(donation);
    _allDonations.add(donation);
    
    await _saveToStorage();
  }

  static Future<List<Map<String, dynamic>>> getDonations(String userId) async {
    await _loadFromStorage();
    return List.from(_donationsByUser[userId] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getAllDonations() async {
    await _loadFromStorage();
    return List.from(_allDonations);
  }

  static Future<void> updateDonationStatus(String userId, int index, String status) async {
    await _loadFromStorage();
    
    if (_donationsByUser.containsKey(userId) && 
        index < _donationsByUser[userId]!.length) {
      _donationsByUser[userId]![index]['status'] = status;
      await _saveToStorage();
    }
  }
}