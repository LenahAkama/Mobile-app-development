import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';

class SharedPreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveEvents(List<Event> events) async {
    final json = jsonEncode(events.map((e) => e.toJson()).toList());
    await _prefs.setString('events', json);
  }

  static List<Event> loadEvents() {
    final json = _prefs.getString('events');
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((item) => Event.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveUserName(String name) async {
    await _prefs.setString('userName', name);
  }

  static String? getUserName() {
    return _prefs.getString('userName');
  }

  static Future<void> saveRegistrations(List<String> registrations) async {
    await _prefs.setStringList('registrations', registrations);
  }

  static List<String> loadRegistrations() {
    return _prefs.getStringList('registrations') ?? [];
  }

  static Future<void> addRegistration(String eventId) async {
    final registrations = loadRegistrations();
    if (!registrations.contains(eventId)) {
      registrations.add(eventId);
      await saveRegistrations(registrations);
    }
  }

  static bool isRegistered(String eventId) {
    return loadRegistrations().contains(eventId);
  }

  static bool getDarkMode() {
    return _prefs.getBool('darkMode') ?? false;
  }

  static Future<void> saveDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
  }
}
