// lib/screens/event_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../theme.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event; // null = create mode

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _capacityCtrl;
  late DateTime _selectedDate;
  late String _selectedCategory;

  bool _isSaving = false;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _capacityCtrl =
        TextEditingController(text: e?.maxCapacity.toString() ?? '100');
    _selectedDate = e?.date ?? DateTime.now().add(const Duration(days: 7));
    _selectedCategory = e?.category ?? kCategories.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kAccent,
            surface: kCard,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kAccent,
            surface: kCard,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<EventProvider>();

    try {
      if (_isEditing) {
        final updated = widget.event!
          ..title = _titleCtrl.text.trim()
          ..description = _descCtrl.text.trim()
          ..location = _locationCtrl.text.trim()
          ..maxCapacity = int.parse(_capacityCtrl.text.trim())
          ..date = _selectedDate
          ..category = _selectedCategory;
        await provider.updateEvent(updated);
      } else {
        await provider.addEvent(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          date: _selectedDate,
          maxCapacity: int.parse(_capacityCtrl.text.trim()),
          category: _selectedCategory,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'New Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionLabel(label: 'Event Title'),
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: kTextPrimary),
              decoration:
                  const InputDecoration(hintText: 'e.g. Tech Summit 2025'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            const _SectionLabel(label: 'Description'),
            TextFormField(
              controller: _descCtrl,
              style: const TextStyle(color: kTextPrimary),
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'Describe your event...'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 16),
            const _SectionLabel(label: 'Location'),
            TextFormField(
              controller: _locationCtrl,
              style: const TextStyle(color: kTextPrimary),
              decoration: const InputDecoration(
                  hintText: 'e.g. Nairobi Convention Centre'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Location is required' : null,
            ),
            const SizedBox(height: 16),
            const _SectionLabel(label: 'Date & Time'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A4060)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: kAccent, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, MMMM d, y • h:mm a')
                          .format(_selectedDate),
                      style: const TextStyle(color: kTextPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel(label: 'Category'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        dropdownColor: kCard,
                        style: const TextStyle(color: kTextPrimary),
                        decoration: const InputDecoration(),
                        items: kCategories
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel(label: 'Max Capacity'),
                      TextFormField(
                        controller: _capacityCtrl,
                        style: const TextStyle(color: kTextPrimary),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '100'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 1) return 'Must be ≥ 1';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kPrimary))
                  : Text(_isEditing ? 'Save Changes' : 'Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: kTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
