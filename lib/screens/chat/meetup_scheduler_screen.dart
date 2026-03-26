import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class MeetupSchedulerScreen extends StatefulWidget {
  final String matchId;
  const MeetupSchedulerScreen({super.key, required this.matchId});

  @override
  State<MeetupSchedulerScreen> createState() => _MeetupSchedulerScreenState();
}

class _MeetupSchedulerScreenState extends State<MeetupSchedulerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  bool _saving = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _scheduleMeetup() async {
    if (_selectedDay == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _saving = true);
    final currentUser = context.read<AuthProvider>().currentUser;

    final meetupDateTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final meetupId = const Uuid().v4();
    await FirebaseFirestore.instance.collection('meetups').doc(meetupId).set({
      'meetupId': meetupId,
      'matchId': widget.matchId,
      'participants': [currentUser?.uid],
      'title': _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'Study Session',
      'dateTime': meetupDateTime,
      'location': _locationController.text.trim(),
      'status': 'scheduled',
      'createdBy': currentUser?.uid,
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meetup scheduled!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Meetup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration()),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(_selectedTime?.format(context) ?? 'Pick a time'),
              onTap: _pickTime,
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (e.g. Math Study Session)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (e.g. Library Room 3)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _scheduleMeetup,
                child: _saving
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Schedule Meetup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
