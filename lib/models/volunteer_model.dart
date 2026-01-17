class Volunteer {
  String id;
  String name;
  String phone;
  String? email;
  String status; // 'active', 'inactive', 'on_leave'
  DateTime createdAt;

  Volunteer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Volunteer.fromMap(Map<String, dynamic> map) {
    return Volunteer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      status: map['status'] ?? 'active',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}

class VolunteerTask {
  String id;
  String donationId;
  String volunteerId;
  String status; // 'assigned', 'in_progress', 'completed', 'cancelled'
  DateTime assignedAt;
  DateTime? completedAt;
  String? notes;

  VolunteerTask({
    required this.id,
    required this.donationId,
    required this.volunteerId,
    this.status = 'assigned',
    DateTime? assignedAt,
    this.completedAt,
    this.notes,
  }) : assignedAt = assignedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donation_id': donationId,
      'volunteer_id': volunteerId,
      'status': status,
      'assigned_at': assignedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory VolunteerTask.fromMap(Map<String, dynamic> map) {
    return VolunteerTask(
      id: map['id'] ?? '',
      donationId: map['donation_id'] ?? '',
      volunteerId: map['volunteer_id'] ?? '',
      status: map['status'] ?? 'assigned',
      assignedAt: map['assigned_at'] != null
          ? DateTime.parse(map['assigned_at'])
          : DateTime.now(),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      notes: map['notes'],
    );
  }
}
