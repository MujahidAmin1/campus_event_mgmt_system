import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:campus_event_mgmt_system/core/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _enableNotifications = true;
  bool _enableReminders = true;
  bool _enableStartNotifications = true;
  bool _enableWeeklyReminders = true;
  bool _enableDayBeforeReminders = true;
  bool _enableHourlyReminders = true;
  bool _enableFifteenMinReminders = true;
  
  int _reminderTime = 30; // minutes before event

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildNotificationSettings(),
            const SizedBox(height: 16),
            _buildReminderSettings(),
            const SizedBox(height: 16),
            _buildTestSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Notification Settings', style: kTextStyle(size: 20, isBold: true)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_active,
              size: 48,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Stay Updated',
            style: kTextStyle(size: 24, isBold: true),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your notification preferences to never miss an event',
            style: kTextStyle(size: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          _buildSettingTile(
            'Enable Notifications',
            'Receive notifications for events and updates',
            Icons.notifications,
            _enableNotifications,
            (value) => setState(() => _enableNotifications = value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Event Reminders',
            'Get reminded about upcoming events',
            Icons.alarm,
            _enableReminders,
            (value) => setState(() => _enableReminders = value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Event Start Notifications',
            'Get notified when events are starting',
            Icons.play_circle,
            _enableStartNotifications,
            (value) => setState(() => _enableStartNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          _buildSettingTile(
            'Weekly Reminders',
            'Get reminded 1 week before events',
            Icons.calendar_view_week,
            _enableWeeklyReminders,
            (value) => setState(() => _enableWeeklyReminders = value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Day Before Reminders',
            'Get reminded 1 day before events',
            Icons.calendar_today,
            _enableDayBeforeReminders,
            (value) => setState(() => _enableDayBeforeReminders = value),
          ),
          _buildDivider(),
          _buildSettingTile(
            '1 Hour Before',
            'Get reminded 1 hour before events',
            Icons.access_time,
            _enableHourlyReminders,
            (value) => setState(() => _enableHourlyReminders = value),
          ),
          _buildDivider(),
          _buildSettingTile(
            '15 Minutes Before',
            'Get reminded 15 minutes before events',
            Icons.timer,
            _enableFifteenMinReminders,
            (value) => setState(() => _enableFifteenMinReminders = value),
          ),
          _buildDivider(),
          _buildReminderTimeSlider(),
        ],
      ),
    );
  }

  Widget _buildReminderTimeSlider() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Reminder Time',
                      style: kTextStyle(size: 16, isBold: true),
                    ),
                    Text(
                      '$_reminderTime minutes before event',
                      style: kTextStyle(size: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _reminderTime.toDouble(),
            min: 5,
            max: 120,
            divisions: 23, // (120-5)/5 = 23 divisions
            activeColor: Colors.blue[700],
            onChanged: (value) {
              setState(() {
                _reminderTime = value.round();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5 min', style: kTextStyle(size: 12, color: Colors.grey[600])),
              Text('120 min', style: kTextStyle(size: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
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
        children: [
          Text(
            'Test Notifications',
            style: kTextStyle(size: 18, isBold: true),
          ),
          const SizedBox(height: 12),
          Text(
            'Send a test notification to verify your settings',
            style: kTextStyle(size: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testNotification,
              icon: const Icon(Icons.send),
              label: const Text('Send Test Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
      title: Text(title, style: kTextStyle(size: 16, isBold: true)),
      subtitle: Text(subtitle, style: kTextStyle(size: 14, color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 56,
    );
  }

  void _testNotification() async {
    try {
      await NotificationService().showImmediateNotification(
        title: 'Test Notification',
        body: 'This is a test notification to verify your settings are working correctly.',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
