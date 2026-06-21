import 'package:uuid/uuid.dart';

class Event {
  final String id;
  final String title;
  final String location;
  final String date;
  final String description;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.description,
  });

  Event copyWith({
    String? id,
    String? title,
    String? location,
    String? date,
    String? description,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date,
      'description': description,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? const Uuid().v4(),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
