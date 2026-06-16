// lib/models/event_model.dart

class Event {
  final String id;
  String title;
  String description;
  String location;
  DateTime date;
  int maxCapacity;
  String category;
  List<Attendee> attendees;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.maxCapacity,
    required this.category,
    List<Attendee>? attendees,
  }) : attendees = attendees ?? [];

  int get registeredCount => attendees.length;
  int get checkedInCount => attendees.where((a) => a.checkedIn).length;
  int get availableSlots => maxCapacity - registeredCount;
  bool get isFull => registeredCount >= maxCapacity;

  double get attendanceRate =>
      registeredCount == 0 ? 0 : (checkedInCount / registeredCount) * 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'maxCapacity': maxCapacity,
      'category': category,
      'attendees': attendees.map((a) => a.toMap()).toList(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      date: DateTime.parse(map['date']),
      maxCapacity: map['maxCapacity'],
      category: map['category'],
      attendees:
          (map['attendees'] as List).map((a) => Attendee.fromMap(a)).toList(),
    );
  }
}

class Attendee {
  final String id;
  String name;
  String email;
  String phone;
  bool checkedIn;
  DateTime registeredAt;
  DateTime? checkedInAt;

  Attendee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.checkedIn = false,
    required this.registeredAt,
    this.checkedInAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'checkedIn': checkedIn,
      'registeredAt': registeredAt.toIso8601String(),
      'checkedInAt': checkedInAt?.toIso8601String(),
    };
  }

  factory Attendee.fromMap(Map<String, dynamic> map) {
    return Attendee(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      checkedIn: map['checkedIn'],
      registeredAt: DateTime.parse(map['registeredAt']),
      checkedInAt: map['checkedInAt'] != null
          ? DateTime.parse(map['checkedInAt'])
          : null,
    );
  }
}
