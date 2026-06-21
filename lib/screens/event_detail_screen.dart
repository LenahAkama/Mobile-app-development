// lib/screens/event_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../theme.dart';
import 'event_form_screen.dart';
import 'registration_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.getEvent(widget.eventId);
        return Scaffold(
          appBar: AppBar(
            title: Text(event.title, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EventFormScreen(event: event))),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: kError),
                onPressed: () => _confirmDelete(context, provider, event),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: kAccent,
              labelColor: kAccent,
              unselectedLabelColor: kTextSecondary,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Attendees'),
                Tab(text: 'Check-In')
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _DetailsTab(event: event),
              _AttendeesTab(event: event),
              _CheckInTab(event: event),
            ],
          ),
          floatingActionButton: event.isFull
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              RegistrationScreen(eventId: event.id))),
                  backgroundColor: kAccent,
                  foregroundColor: kPrimary,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, EventProvider provider, Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        title:
            const Text('Delete Event?', style: TextStyle(color: kTextPrimary)),
        content: Text('Are you sure you want to delete "${event.title}"?',
            style: const TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: kError),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await provider.deleteEvent(event.id);
      Navigator.pop(context);
    }
  }
}

// ── Details Tab ───────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  final Event event;
  const _DetailsTab({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d, y • h:mm a').format(event.date);
    final fillPercent =
        event.maxCapacity > 0 ? event.registeredCount / event.maxCapacity : 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kAccent.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryBadge(label: event.category),
                  const Spacer(),
                  if (event.isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: kError.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('FULL',
                          style: TextStyle(
                              color: kError,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(event.title,
                  style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.calendar_today, size: 16, color: kAccent),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(dateStr,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 13)))
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_on, size: 16, color: kAccent),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(event.location,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 13)))
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: kCard, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Capacity',
                  style: TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CapStat(
                      label: 'Registered',
                      value: '${event.registeredCount}',
                      color: kAccent),
                  _CapStat(
                      label: 'Available',
                      value: '${event.availableSlots}',
                      color: const Color(0xFF7B61FF)),
                  _CapStat(
                      label: 'Checked In',
                      value: '${event.checkedInCount}',
                      color: kWarning),
                  _CapStat(
                      label: 'Capacity',
                      value: '${event.maxCapacity}',
                      color: kTextSecondary),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fillPercent.clamp(0.0, 1.0),
                  backgroundColor: kSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      event.isFull ? kError : kAccent),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text('${(fillPercent * 100).toStringAsFixed(0)}% capacity filled',
                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: kCard, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('About',
                  style: TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(height: 10),
              Text(event.description,
                  style: const TextStyle(
                      color: kTextSecondary, fontSize: 14, height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CapStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _CapStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: kTextSecondary, fontSize: 10)),
      ],
    );
  }
}

// ── Attendees Tab ─────────────────────────────────────────

class _AttendeesTab extends StatelessWidget {
  final Event event;
  const _AttendeesTab({required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.attendees.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 56, color: kTextSecondary),
            SizedBox(height: 12),
            Text('No registrations yet',
                style: TextStyle(color: kTextSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: event.attendees.length,
      itemBuilder: (ctx, i) {
        final a = event.attendees[i];
        return _AttendeeCard(
            attendee: a, onRemove: () => _confirmRemove(ctx, event.id, a));
      },
    );
  }

  Future<void> _confirmRemove(
      BuildContext ctx, String eventId, Attendee a) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Remove Attendee?',
            style: TextStyle(color: kTextPrimary)),
        content: Text('Remove ${a.name} from this event?',
            style: const TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: kError),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      ctx.read<EventProvider>().removeAttendee(eventId, a.id);
    }
  }
}

class _AttendeeCard extends StatelessWidget {
  final Attendee attendee;
  final VoidCallback onRemove;
  const _AttendeeCard({required this.attendee, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: attendee.checkedIn
                ? kAccent.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: kAccent.withValues(alpha: 0.15),
            child: Text(attendee.name[0].toUpperCase(),
                style: const TextStyle(
                    color: kAccent, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attendee.name,
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(attendee.email,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 12)),
                Text(attendee.phone,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (attendee.checkedIn)
                const Icon(Icons.check_circle, color: kAccent, size: 18),
              const SizedBox(height: 4),
              GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.close, color: kError, size: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Check-In Tab ──────────────────────────────────────────

class _CheckInTab extends StatefulWidget {
  final Event event;
  const _CheckInTab({required this.event});

  @override
  State<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<_CheckInTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final attendees = widget.event.attendees
        .where((a) =>
            a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.email.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final checkedIn = widget.event.attendees.where((a) => a.checkedIn).length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: kSurface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '$checkedIn / ${widget.event.registeredCount} checked in',
                        style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text(
                        '${widget.event.attendanceRate.toStringAsFixed(0)}% attendance rate',
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (widget.event.attendees.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      context.read<EventProvider>().checkInAll(widget.event.id),
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Check In All'),
                  style: TextButton.styleFrom(foregroundColor: kAccent),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: kTextPrimary),
            decoration: const InputDecoration(
              hintText: 'Search attendee...',
              prefixIcon: Icon(Icons.search, color: kTextSecondary, size: 18),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: attendees.isEmpty
              ? const Center(
                  child: Text('No attendees found',
                      style: TextStyle(color: kTextSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: attendees.length,
                  itemBuilder: (_, i) => _CheckInRow(
                      attendee: attendees[i], eventId: widget.event.id),
                ),
        ),
      ],
    );
  }
}

class _CheckInRow extends StatelessWidget {
  final Attendee attendee;
  final String eventId;
  const _CheckInRow({required this.attendee, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: attendee.checkedIn ? kAccent.withValues(alpha: 0.08) : kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: attendee.checkedIn
                ? kAccent.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: kAccent.withValues(alpha: 0.15),
            child: Text(attendee.name[0].toUpperCase(),
                style: const TextStyle(
                    color: kAccent, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attendee.name,
                    style: TextStyle(
                        color:
                            attendee.checkedIn ? kTextPrimary : kTextSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(attendee.email,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context
                .read<EventProvider>()
                .toggleCheckIn(eventId, attendee.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: attendee.checkedIn ? kAccent : kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: attendee.checkedIn ? kAccent : kTextSecondary,
                    width: 1.5),
              ),
              child: Icon(attendee.checkedIn ? Icons.check : Icons.add,
                  color: attendee.checkedIn ? kPrimary : kTextSecondary,
                  size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
