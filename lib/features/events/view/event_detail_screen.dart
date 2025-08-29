import 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider to check if user is registered for an event
final isEventRegisteredProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final userId = params['userId']!;
  final eventId = params['eventId']!;
  final firestore = FirebaseFirestore.instance;
  final doc = await firestore
      .collection('users')
      .doc(userId)
      .collection('registeredEvents')
      .doc(eventId)
      .get();
  return doc.exists;
});

class EventDetailScreen extends ConsumerWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isRegisteredAsync = ref.watch(isEventRegisteredProvider({'userId': userId, 'eventId': event.id}));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Event Details', style: kTextStyle(size: 20, isBold: true)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDetailsCard(),
            const SizedBox(height: 24),
            _buildRegistrationSection(context, isRegisteredAsync, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.title, style: kTextStyle(size: 22, isBold: true)),
          const SizedBox(height: 8),
          Text(event.description, style: kTextStyle(size: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(DateFormat('EEEE, MMMM d, yyyy').format(event.startDateTime),
                  style: kTextStyle(size: 16)),
              const SizedBox(width: 8),
              Text(DateFormat('h:mm a').format(event.startDateTime),
                  style: kTextStyle(size: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event Details', style: kTextStyle(size: 16, isBold: true)),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.location_on, 'Venue', event.venue),
          _buildDetailItem(Icons.person, 'Organiser', event.organizerName),
          _buildDetailItem(Icons.group, 'Registered', '${event.registeredUsers} members'),
          _buildDetailItem(Icons.access_time, 'Duration',
              '${event.endDateTime.difference(event.startDateTime).inHours} hours'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: kTextStyle(size: 12, color: Colors.grey[600])),
              Text(value, style: kTextStyle(size: 16, isBold: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationSection(BuildContext context, AsyncValue<bool> isRegisteredAsync, WidgetRef ref) {
    if (event.isPast) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('This event has ended', style: kTextStyle(size: 18, isBold: true)),
            const SizedBox(height: 8),
            Text('Thank you for participating!', style: kTextStyle(size: 14, color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (event.isOngoing) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.event_note, size: 48, color: Colors.green[600]),
            const SizedBox(height: 12),
            Text('Event is currently happening',
                style: kTextStyle(size: 18, isBold: true, color: Colors.green[700])),
            const SizedBox(height: 8),
            Text('Head to ${event.venue} to join!',
                style: kTextStyle(size: 14, color: Colors.green[600])),
          ],
        ),
      );
    }

    // Upcoming event info and registration button (blue card)
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ready to Join?', style: kTextStyle(size: 16, color: Colors.blue[700])),
                  Text('${event.registeredUsers} people have registered already',
                      style: kTextStyle(size: 14, color: Colors.blue[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          isRegisteredAsync.when(
            data: (isRegistered) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isRegistered ? null : () => _handleRegister(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRegistered ? Colors.grey : Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isRegistered ? 'Registered' : 'Register for Event',
                  style: kTextStyle(size: 16, isBold: true, color: Colors.white),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Unable to check registration',
                  style: kTextStyle(size: 16, isBold: true, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister(BuildContext context, WidgetRef ref) async {
    ref.read(eventsProvider.notifier).registerForEvent(FirebaseAuth.instance.currentUser!.uid, event);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully registered for ${event.title}')),
    );
  }
}
