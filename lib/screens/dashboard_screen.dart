// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../theme.dart';
import 'event_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: kAccent));
        }

        final upcoming = provider.upcomingEvents;
        final past = provider.pastEvents;
        final totalCheckedIn =
            provider.events.fold<int>(0, (sum, e) => sum + e.checkedInCount);

        return Scaffold(
          appBar: AppBar(
            title: const Text('EventPulse'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: const CircleAvatar(
                  backgroundColor: kSurface,
                  child: Icon(Icons.person, color: kAccent, size: 20),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: kAccent,
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 13,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Event Dashboard',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                        label: 'Total Events',
                        value: '${provider.events.length}',
                        icon: Icons.event,
                        color: kAccent),
                    _StatCard(
                        label: 'Upcoming',
                        value: '${upcoming.length}',
                        icon: Icons.upcoming,
                        color: const Color(0xFF7B61FF)),
                    _StatCard(
                        label: 'Registrations',
                        value: '${provider.totalAttendees}',
                        icon: Icons.people,
                        color: const Color(0xFFFFB347)),
                    _StatCard(
                        label: 'Checked In',
                        value: '$totalCheckedIn',
                        icon: Icons.how_to_reg,
                        color: const Color(0xFFFF6B6B)),
                  ],
                ),
                const SizedBox(height: 28),
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(
                      title: 'Upcoming Events', count: upcoming.length),
                  const SizedBox(height: 12),
                  ...upcoming.take(3).map((e) => _EventSummaryCard(event: e)),
                  const SizedBox(height: 28),
                ],
                if (past.isNotEmpty) ...[
                  _SectionHeader(title: 'Past Events', count: past.length),
                  const SizedBox(height: 12),
                  ...past
                      .take(3)
                      .map((e) => _EventSummaryCard(event: e, isPast: true)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color, fontSize: 24, fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(color: kTextSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12)),
          child: Text('$count',
              style: const TextStyle(
                  color: kAccent, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  final Event event;
  final bool isPast;
  const _EventSummaryCard({required this.event, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d • h:mm a').format(event.date);
    final fillPercent =
        event.maxCapacity > 0 ? event.registeredCount / event.maxCapacity : 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isPast
                  ? Colors.white.withValues(alpha: 0.05)
                  : kAccent.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(event.title,
                      style: TextStyle(
                          color: isPast ? kTextSecondary : kTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                CategoryBadge(label: event.category),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 13, color: kTextSecondary),
                const SizedBox(width: 4),
                Text(dateStr,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.location_on, size: 13, color: kTextSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(event.location,
                      style:
                          const TextStyle(color: kTextSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fillPercent.clamp(0.0, 1.0),
                      backgroundColor: kSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          event.isFull ? kError : kAccent),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${event.registeredCount}/${event.maxCapacity}',
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
