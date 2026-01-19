import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalRequestService {
  static final List<Map<String, dynamic>> _requests = [];
  static bool _isLoaded = false;

  static Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getString('requests');
    
    if (requestsJson != null) {
      final List<dynamic> requestsList = json.decode(requestsJson);
      _requests.clear();
      _requests.addAll(requestsList.cast<Map<String, dynamic>>());
    }
    
    _isLoaded = true;
  }

  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('requests', json.encode(_requests));
  }

  static Future<void> addRequest({
    required String donationId,
    required String recipientId,
    required String donorId,
    required String foodItem,
    required String quantity,
    required String location,
  }) async {
    await _loadFromStorage();
    
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
    
    await _saveToStorage();
  }

  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    await _loadFromStorage();
    return _requests.where((r) => r['status'] == 'Pending').toList();
  }

  static Future<void> updateRequestStatus(String requestId, String status, {String? volunteerId}) async {
    await _loadFromStorage();
    
    final index = _requests.indexWhere((r) => r['id'] == requestId);
    if (index != -1) {
      _requests[index]['status'] = status;
      if (volunteerId != null) {
        _requests[index]['volunteerId'] = volunteerId;
        _requests[index]['assignedDate'] = DateTime.now().toString().split(' ')[0];
      }
      await _saveToStorage();
    }
  }
}