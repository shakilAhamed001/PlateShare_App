import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalVolunteerService {
  static final List<Map<String, dynamic>> _volunteers = [];
  static bool _isLoaded = false;

  static Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    
    final prefs = await SharedPreferences.getInstance();
    final volunteersJson = prefs.getString('volunteers');
    
    if (volunteersJson != null) {
      final List<dynamic> volunteersList = json.decode(volunteersJson);
      _volunteers.clear();
      _volunteers.addAll(volunteersList.cast<Map<String, dynamic>>());
    } else {
      // Add some default volunteers for testing
      _volunteers.addAll([
        {
          'id': '1',
          'name': 'Ahmed Volunteer',
          'phone': '01700000001',
          'email': 'ahmed@volunteer.com',
          'address': 'Dhaka, Bangladesh',
          'status': 'Available',
        },
        {
          'id': '2', 
          'name': 'Fatima Volunteer',
          'phone': '01700000002',
          'email': 'fatima@volunteer.com',
          'address': 'Chittagong, Bangladesh',
          'status': 'Available',
        },
        {
          'id': '3',
          'name': 'Rahman Volunteer', 
          'phone': '01700000003',
          'email': 'rahman@volunteer.com',
          'address': 'Sylhet, Bangladesh',
          'status': 'Available',
        },
      ]);
      await _saveToStorage();
    }
    
    _isLoaded = true;
  }

  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('volunteers', json.encode(_volunteers));
  }

  static Future<void> addVolunteer(Map<String, dynamic> volunteer) async {
    await _loadFromStorage();
    volunteer['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    volunteer['status'] = 'Available';
    _volunteers.add(volunteer);
    await _saveToStorage();
  }

  static Future<List<Map<String, dynamic>>> getAvailableVolunteers() async {
    await _loadFromStorage();
    return _volunteers.where((v) => v['status'] == 'Available').toList();
  }

  static Future<void> updateVolunteerStatus(String volunteerId, String status) async {
    await _loadFromStorage();
    final index = _volunteers.indexWhere((v) => v['id'] == volunteerId);
    if (index != -1) {
      _volunteers[index]['status'] = status;
      await _saveToStorage();
    }
  }
}