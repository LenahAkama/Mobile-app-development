// lib/screens/events_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../theme.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _filter(event) {
    final matchesSearch = _searchQuery.isEmpty ||
        event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        event.location.toLowerCase().contains(_searchQuery.toLowerCase());
    final matchesCategory =
        _selectedCategory == null || event.category == _selectedCategory;
    return matchesSearch && matchesCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(builder: (context, provider, _) {
      final upcoming = provider.upcomingEvents.where(_filter).toList();
      final past = provider.pastEvents.where(_filter).toList();

      return Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: kAccent,
            labelColor: kAccent,
            unselectedLabelColor: kTextSecondary,
            tabs: [
              Tab(text: 'Upcoming (${upcoming.length})'),
              Tab(text: 'Past (${past.length})'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const EventFormScreen())),
          backgroundColor: kAccent,
          foregroundColor: kPrimary,
          icon: const Icon(Icons.add),
          label: const Text('New Event',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: kTextPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: Icon(Icons.search, color: kTextSecondary),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String?>(
                    color: kCard,
                    icon: Badge(
                      isLabelVisible: _selectedCategory != null,
                      backgroundColor: kAccent,
                      child:
                          const Icon(Icons.filter_list, color: kTextSecondary),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: null,
                          child: Text('All Categories',
                              style: TextStyle(color: kTextPrimary))),
                      ...kCategories.map((c) => PopupMenuItem(
                          value: c,
                          child: Text(c,
                              style: const TextStyle(color: kTextPrimary)))),
                    ],
                    onSelected: (v) => setState(() => _selectedCategory = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _EventList(events: upcoming),
                  _EventList(events: past, isPast: true),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _EventList extends StatelessWidget {
  final List events;
  final bool isPast;
  const _EventList({required this.events, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPast ? Icons.history : Icons.event_available,
                color: kTextSecondary, size: 56),
            const SizedBox(height: 12),
            Text(isPast ? 'No past events' : 'No upcoming events',
                style: const TextStyle(color: kTextSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (ctx, i) => _EventCard(event: events[i], isPast: isPast),
    );
  }
}

class _EventCard extends StatelessWidget {
  final dynamic event;
  final bool isPast;
  const _EventCard({required this.event, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(event.date);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isPast
                  ? Colors.white.withValues(alpha: 0.05)
                  : kAccent.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isPast ? kSurface : kAccent.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('MMM').format(event.date).toUpperCase(),
                      style: TextStyle(
                          color: isPast ? kTextSecondary : kAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  Text(DateFormat('d').format(event.date),
                      style: TextStyle(
                          color: isPast ? kTextSecondary : kTextPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  Text(timeStr,
                      style:
                          const TextStyle(color: kTextSecondary, fontSize: 10),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(event.title,
                              style: TextStyle(
                                  color: isPast ? kTextSecondary : kTextPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        CategoryBadge(label: event.category),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: kTextSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(event.location,
                              style: const TextStyle(
                                  color: kTextSecondary, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.people,
                            size: 13, color: kTextSecondary),
                        const SizedBox(width: 4),
                        Text('${event.registeredCount} registered',
                            style: const TextStyle(
                                color: kTextSecondary, fontSize: 11)),
                        const Spacer(),
                        if (event.isFull)
                          const _Badge(label: 'FULL', color: kError)
                        else if (!isPast)
                          _Badge(
                              label: '${event.availableSlots} left',
                              color: kAccent),
                        if (isPast)
                          _Badge(
                              label:
                                  '${event.attendanceRate.toStringAsFixed(0)}% attended',
                              color: kWarning),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
