import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/event.dart';
import '../services/shared_preferences_service.dart';
import 'event_detail_page.dart';
import 'event_form_page.dart';
import 'users_page.dart';

class EventListPage extends StatefulWidget {
  final VoidCallback? onThemeToggle;

  const EventListPage({super.key, this.onThemeToggle});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late List<Event> _events;
  String _searchQuery = '';
  String? _userName;
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _events = SharedPreferencesService.loadEvents();
      _userName = SharedPreferencesService.getUserName();

      if (_events.isEmpty) {
        _events = [
          Event(
            id: const Uuid().v4(),
            title: 'Community Hackathon',
            location: 'Downtown Innovation Hub',
            date: '2026-06-25',
            description:
                'Build solutions with local developers, designers, and entrepreneurs.',
          ),
          Event(
            id: const Uuid().v4(),
            title: 'Wellness Workshop',
            location: 'City Health Center',
            date: '2026-07-03',
            description:
                'A guided workshop about mental health, nutrition, and self-care.',
          ),
        ];
        _saveEvents();
      }
    });
  }

  void _saveEvents() {
    SharedPreferencesService.saveEvents(_events);
  }

  List<Event> get _filteredEvents {
    var filtered = _searchQuery.isEmpty
        ? _events
        : _events.where((event) {
            final query = _searchQuery.toLowerCase();
            return event.title.toLowerCase().contains(query) ||
                event.location.toLowerCase().contains(query) ||
                event.description.toLowerCase().contains(query) ||
                event.date.toLowerCase().contains(query);
          }).toList();

    switch (_sortBy) {
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'location':
        filtered.sort((a, b) => a.location.compareTo(b.location));
        break;
      case 'date':
      default:
        filtered.sort((a, b) => a.date.compareTo(b.date));
    }

    return filtered;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openEventForm({Event? event}) async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormPage(event: event),
      ),
    );

    if (result == null) return;

    setState(() {
      final index = _events.indexWhere((item) => item.id == result.id);
      if (index == -1) {
        _events.add(result);
        _showSnackBar('Event added successfully');
      } else {
        _events[index] = result;
        _showSnackBar('Event updated successfully');
      }
      _saveEvents();
    });
  }

  void _deleteEvent(Event event) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete event'),
          content: Text('Are you sure you want to delete "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _events.removeWhere((item) => item.id == event.id);
          _saveEvents();
        });
        _showSnackBar('Event deleted');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Manager'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Users',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UsersPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              _showProfileDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_4),
            tooltip: 'Toggle theme',
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            if (_userName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Welcome, $_userName! 👋',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              decoration: InputDecoration(
                labelText: 'Search events',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.sort, size: 20),
                const SizedBox(width: 8),
                const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Date')),
                      DropdownMenuItem(value: 'title', child: Text('Title')),
                      DropdownMenuItem(value: 'location', child: Text('Location')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredEvents.isEmpty
                  ? const Center(
                      child: Text('No events found.'),
                    )
                  : ListView.separated(
                      itemCount: _filteredEvents.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        final isRegistered =
                            SharedPreferencesService.isRegistered(event.id);
                        return ListTile(
                          title: Text(event.title),
                          subtitle: Text('${event.date} · ${event.location}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isRegistered)
                                Tooltip(
                                  message: 'Registered',
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openEventForm(event: event),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () => _deleteEvent(event),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailPage(event: event),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEventForm(),
        tooltip: 'Add event',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProfileDialog() {
    final controller = TextEditingController(text: _userName ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Your Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  SharedPreferencesService.saveUserName(name);
                  setState(() {
                    _userName = name;
                  });
                  Navigator.pop(context);
                  _showSnackBar('Name saved!');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
