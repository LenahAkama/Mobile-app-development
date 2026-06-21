import 'package:flutter/material.dart';

import 'pages/event_list_page.dart';
import 'services/shared_preferences_service.dart';

class EventManagerApp extends StatefulWidget {
  const EventManagerApp({super.key});

  @override
  State<EventManagerApp> createState() => _EventManagerAppState();
}

class _EventManagerAppState extends State<EventManagerApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() {
    setState(() {
      _isDarkMode = SharedPreferencesService.getDarkMode();
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      SharedPreferencesService.saveDarkMode(_isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: EventListPage(onThemeToggle: _toggleDarkMode),
    );
  }
}
