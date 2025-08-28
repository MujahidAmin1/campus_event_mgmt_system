import 'package:flutter/material.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 24),
            _buildDetails(),
            const SizedBox(height: 24),
            _buildInfoContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(),
          const SizedBox(height: 16),
          Text(event.title, style: kTextStyle(size: 24, isBold: true)),
          const SizedBox(height: 8),
          Text(event.venue, style: kTextStyle(size: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Text(
            DateFormat('EEEE, MMMM dd, yyyy – hh:mm a').format(event.startDateTime),
            style: kTextStyle(size: 16, isBold: true),
          ),
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
          Text(statusText, style: kTextStyle(size: 12, isBold: true, color: badgeColor)),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About This Event', style: kTextStyle(size: 18, isBold: true)),
          const SizedBox(height: 12),
          Text(event.description, style: kTextStyle(size: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event Details', style: kTextStyle(size: 18, isBold: true)),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.location_on, 'Venue', event.venue),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.person, 'Organizer', event.organizerName),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.people, 'Registered', '${event.registeredUsers} participants'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.access_time, 'Duration', '${event.endDateTime.difference(event.startDateTime).inHours} hours'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: kTextStyle(size: 12, color: Colors.grey[500])),
            Text(value, style: kTextStyle(size: 16, isBold: true)),
          ],
        )
      ],
    );
  }

  Widget _buildInfoContainer() {
    MaterialColor color;
    String title;
    String subtitle;

    if (event.isPast) {
      color = Colors.grey;
      title = 'Event Ended';
      subtitle = 'Thank you for participating!';
    } else if (event.isOngoing) {
      color = Colors.green;
      title = 'Ongoing Event';
      subtitle = 'Join now at ${event.venue}';
    } else {
      color = Colors.blue;
      title = 'Upcoming Event';
      subtitle = 'Don’t miss out!';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.info, size: 48, color: color.shade600),
          const SizedBox(height: 12),
          Text(title, style: kTextStyle(size: 18, isBold: true, color: color.shade700)),
          const SizedBox(height: 8),
          Text(subtitle, style: kTextStyle(size: 14, color: color.shade600)),
        ],
      ),
    );
  }
}
