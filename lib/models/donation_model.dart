class Donation {
  String id;
  String name;
  String phone;
  String address;
  String source;
  String quantity;
  String ngo;
  List<String>? imagePaths;
  String status; // 'available', 'requested', 'approved', 'rejected'
  String donorId; // for simplicity, use name or something

  Donation({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.source,
    required this.quantity,
    required this.ngo,
    this.imagePaths,
    this.status = 'available',
    required this.donorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'source': source,
      'quantity': quantity,
      'ngo': ngo,
      'imagePaths': imagePaths,
      'status': status,
      'donorId': donorId,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      source: map['source'],
      quantity: map['quantity'],
      ngo: map['ngo'],
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
      status: map['status'],
      donorId: map['donorId'],
    );
  }
}

class FoodRequest {
  String id;
  String donationId;
  String recipientId; // use name
  String status; // 'pending', 'approved', 'rejected'
  DateTime requestTime;

  FoodRequest({
    required this.id,
    required this.donationId,
    required this.recipientId,
    this.status = 'pending',
    DateTime? requestTime,
  }) : requestTime = requestTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donationId': donationId,
      'recipientId': recipientId,
      'status': status,
      'requestTime': requestTime.toIso8601String(),
    };
  }

  factory FoodRequest.fromMap(Map<String, dynamic> map) {
    return FoodRequest(
      id: map['id'],
      donationId: map['donationId'],
      recipientId: map['recipientId'],
      status: map['status'],
      requestTime: DateTime.parse(map['requestTime']),
    );
  }
}