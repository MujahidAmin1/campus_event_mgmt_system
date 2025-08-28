import 'package:flutter/material.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onRegister;
  final bool isRegistered;
  final bool showRegisterButton;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onRegister,
    this.isRegistered = false,
    this.showRegisterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildDescription(),
              const SizedBox(height: 12),
              _buildEventDetails(),
              const SizedBox(height: 12),
              _buildBottomRow(),
              if (_shouldShowRegisterButton()) ...[
                const SizedBox(height: 12),
                _buildRegisterButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Text(
        event.title,
        style: kTextStyle(size: 18, isBold: true),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildDescription() => Text(
        event.description,
        style: kTextStyle(size: 14, color: Colors.grey[600]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildEventDetails() {
    return Row(
      children: [
        _buildDetailItem(
          Icons.calendar_today,
          "${DateFormat('MMM dd, yyyy').format(event.startDateTime)} - ${DateFormat('hh:mm a').format(event.startDateTime)}",
        ),
        const SizedBox(width: 16),
        _buildDetailItem(Icons.location_on, event.venue),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: kTextStyle(size: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            event.organizerName,
            style: kTextStyle(size: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildParticipantCount(),
      ],
    );
  }

  Widget _buildParticipantCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            '${event.registeredUsers}',
            style: kTextStyle(size: 12, isBold: true, color: Colors.blue[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isRegistered ? null : onRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRegistered ? Colors.grey : Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          isRegistered ? 'Registered' : 'Register',
          style: kTextStyle(size: 14, isBold: true, color: Colors.white),
        ),
      ),
    );
  }

  bool _shouldShowRegisterButton() {
    return showRegisterButton && event.isUpcoming && !event.isPast;
  }
}
