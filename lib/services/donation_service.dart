class DonationService {
  static final List<Map<String, dynamic>> _donations = [];

  static void addDonation(Map<String, dynamic> donation) {
    _donations.add(donation);
  }

  static List<Map<String, dynamic>> getDonations() {
    return List.from(_donations);
  }

  static void updateDonationStatus(int index, String status) {
    if (index < _donations.length) {
      _donations[index]['status'] = status;
    }
  }
}