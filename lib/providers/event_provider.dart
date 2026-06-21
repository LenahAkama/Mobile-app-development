// lib/providers/event_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';

const _uuid = Uuid();

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;

  List<Event> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;

  List<Event> get upcomingEvents =>
      _events.where((e) => e.date.isAfter(DateTime.now())).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<Event> get pastEvents =>
      _events.where((e) => e.date.isBefore(DateTime.now())).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  int get totalAttendees =>
      _events.fold(0, (sum, e) => sum + e.registeredCount);

  EventProvider() {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('events');
      if (data != null) {
        final List decoded = jsonDecode(data);
        _events = decoded.map((e) => Event.fromMap(e)).toList();
      } else {
        _events = _sampleEvents();
      }
    } catch (_) {
      _events = _sampleEvents();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_events.map((e) => e.toMap()).toList());
    await prefs.setString('events', data);
  }

  // ── CRUD ───────────────────────────────────────────────

  Future<void> addEvent({
    required String title,
    required String description,
    required String location,
    required DateTime date,
    required int maxCapacity,
    required String category,
  }) async {
    final event = Event(
      id: _uuid.v4(),
      title: title,
      description: description,
      location: location,
      date: date,
      maxCapacity: maxCapacity,
      category: category,
    );
    _events.add(event);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> updateEvent(Event updated) async {
    final idx = _events.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _events[idx] = updated;
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    await _saveEvents();
    notifyListeners();
  }

  // ── REGISTRATION ────────────────────────────────────────

  Future<bool> registerAttendee({
    required String eventId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    if (event.isFull) return false;
    if (event.attendees.any((a) => a.email == email)) return false;

    event.attendees.add(Attendee(
      id: _uuid.v4(),
      name: name,
      email: email,
      phone: phone,
      registeredAt: DateTime.now(),
    ));
    await _saveEvents();
    notifyListeners();
    return true;
  }

  Future<void> removeAttendee(String eventId, String attendeeId) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    event.attendees.removeWhere((a) => a.id == attendeeId);
    await _saveEvents();
    notifyListeners();
  }

  // ── ATTENDANCE ─────────────────────────────────────────

  Future<void> toggleCheckIn(String eventId, String attendeeId) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    final attendee = event.attendees.firstWhere((a) => a.id == attendeeId);
    attendee.checkedIn = !attendee.checkedIn;
    attendee.checkedInAt = attendee.checkedIn ? DateTime.now() : null;
    await _saveEvents();
    notifyListeners();
  }

  Future<void> checkInAll(String eventId) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    for (final a in event.attendees) {
      a.checkedIn = true;
      a.checkedInAt ??= DateTime.now();
    }
    await _saveEvents();
    notifyListeners();
  }

  Event getEvent(String id) => _events.firstWhere((e) => e.id == id);

  // ── SAMPLE DATA ────────────────────────────────────────

  List<Event> _sampleEvents() {
    return [
      Event(
        id: _uuid.v4(),
        title: 'Tech Summit 2025',
        description:
            'Annual technology summit featuring keynotes, workshops, and networking with industry leaders.',
        location: 'Nairobi Convention Centre',
        date: DateTime.now().add(const Duration(days: 7)),
        maxCapacity: 200,
        category: 'Technology',
        attendees: [
          Attendee(
            id: _uuid.v4(),
            name: 'Alice Wanjiku',
            email: 'alice@example.com',
            phone: '+254701000001',
            registeredAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          Attendee(
            id: _uuid.v4(),
            name: 'Brian Omondi',
            email: 'brian@example.com',
            phone: '+254701000002',
            checkedIn: true,
            registeredAt: DateTime.now().subtract(const Duration(days: 1)),
            checkedInAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      Event(
        id: _uuid.v4(),
        title: 'Product Design Workshop',
        description:
            'Hands-on UX/UI design workshop for beginners and intermediate designers.',
        location: 'iHub, Nairobi',
        date: DateTime.now().add(const Duration(days: 14)),
        maxCapacity: 50,
        category: 'Design',
      ),
      Event(
        id: _uuid.v4(),
        title: 'Startup Pitch Night',
        description:
            'Emerging startups pitch to a panel of investors and mentors.',
        location: 'Strathmore University',
        date: DateTime.now().subtract(const Duration(days: 3)),
        maxCapacity: 100,
        category: 'Business',
        attendees: [
          Attendee(
            id: _uuid.v4(),
            name: 'Carol Muthoni',
            email: 'carol@example.com',
            phone: '+254701000003',
            checkedIn: true,
            registeredAt: DateTime.now().subtract(const Duration(days: 10)),
            checkedInAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      ),
    ];
  }
}
