class AppNotification {
  String id;
  String recipientId;
  String message;
  String donationId;
  bool read;
  DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientId,
    required this.message,
    required this.donationId,
    this.read = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      recipientId: map['recipient_id'],
      message: map['message'],
      donationId: map['donation_id'] ?? '',
      read: map['read'] ?? false,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
