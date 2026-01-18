class LocalRequestService {
  static final List<Map<String, dynamic>> _requests = [];

  static void addRequest({
    required String donationId,
    required String recipientId,
    required String donorId,
    required String foodItem,
    required String quantity,
    required String location,
  }) {
    _requests.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'donationId': donationId,
      'recipientId': recipientId,
      'donorId': donorId,
      'foodItem': foodItem,
      'quantity': quantity,
      'location': location,
      'status': 'Pending',
      'requestDate': DateTime.now().toString().split(' ')[0],
    });
  }

  static List<Map<String, dynamic>> getPendingRequests() {
    return _requests.where((r) => r['status'] == 'Pending').toList();
  }

  static void updateRequestStatus(String requestId, String status) {
    final index = _requests.indexWhere((r) => r['id'] == requestId);
    if (index != -1) {
      _requests[index]['status'] = status;
    }
  }
}