import 'package:flutter/material.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:campus_event_mgmt_system/core/services/notification_service.dart';
import 'package:campus_event_mgmt_system/features/events/view/my_events_screen.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventHeader(),
            const SizedBox(height: 16),
            _buildEventContent(),
            const SizedBox(height: 24),
            _buildEventDetails(),
            const SizedBox(height: 24),
            _buildRegistrationSection(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Event Details', style: kTextStyle(size: 20, isBold: true)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(),
          const SizedBox(height: 16),
          Text(
            event.title,
            style: kTextStyle(size: 24, isBold: true),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: kTextStyle(size: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _buildDateTimeInfo(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (event.isPast) {
      badgeColor = Colors.grey;
      statusText = 'Past Event';
      statusIcon = Icons.history;
    } else if (event.isOngoing) {
      badgeColor = Colors.green;
      statusText = 'Ongoing';
      statusIcon = Icons.event_note;
    } else {
      badgeColor = Colors.blue;
      statusText = 'Upcoming';
      statusIcon = Icons.event;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: kTextStyle(size: 12, isBold: true, color: badgeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.calendar_today, color: Colors.blue[700], size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM dd, yyyy').format(event.dateTime),
                style: kTextStyle(size: 16, isBold: true),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(event.dateTime),
                style: kTextStyle(size: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Event',
            style: kTextStyle(size: 18, isBold: true),
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: kTextStyle(size: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: kTextStyle(size: 18, isBold: true),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.location_on, 'Venue', event.venue),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.person, 'Organizer', event.organizerName),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.people, 'Registered', '${event.registeredUsers} participants'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.access_time, 'Duration', '3 hours'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: kTextStyle(size: 12, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: kTextStyle(size: 16, isBold: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationSection(BuildContext context) {
    if (event.isPast) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'This event has ended',
              style: kTextStyle(size: 18, isBold: true),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you for participating!',
              style: kTextStyle(size: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (event.isOngoing) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
            Text(
              'Event is currently happening',
              style: kTextStyle(size: 18, isBold: true, color: Colors.green[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Head to ${event.venue} to join!',
              style: kTextStyle(size: 14, color: Colors.green[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Icon(Icons.event, size: 24, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to join?',
                      style: kTextStyle(size: 18, isBold: true, color: Colors.blue[700]),
                    ),
                    Text(
                      '${event.registeredUsers} people have registered',
                      style: kTextStyle(size: 14, color: Colors.blue[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleRegister(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Register for Event',
                style: kTextStyle(size: 16, isBold: true, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister(BuildContext context) async {
    try {
      // Schedule smart reminders for the event
      await NotificationService().scheduleSmartReminders(event);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully registered for ${event.title}. Reminders scheduled!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View My Events',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to My Events screen
              Navigator.pop(context); // Close current screen
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const MyEventsScreen(),
              ));
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registered successfully, but failed to schedule reminders: $e'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
