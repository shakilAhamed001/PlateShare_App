class LocalDonationService {
  static final Map<String, List<Map<String, dynamic>>> _donationsByUser = {};
  static final List<Map<String, dynamic>> _allDonations = [];

  static void addDonation(String userId, Map<String, dynamic> donation) {
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
    
    _donationsByUser[userId]!.add(donation);
    _allDonations.add(donation);
  }

  static List<Map<String, dynamic>> getDonations(String userId) {
    return List.from(_donationsByUser[userId] ?? []);
  }

  static List<Map<String, dynamic>> getAllDonations() {
    return List.from(_allDonations);
  }

  static void updateDonationStatus(String userId, int index, String status) {
    if (_donationsByUser.containsKey(userId) && 
        index < _donationsByUser[userId]!.length) {
      _donationsByUser[userId]![index]['status'] = status;
    }
  }
}