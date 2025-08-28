import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';

class EventInputDialog extends ConsumerStatefulWidget {
  BuildContext context;
  EventInputDialog({super.key, required this.context});

  @override
  ConsumerState<EventInputDialog> createState() => _EventInputDialogState();
}

class _EventInputDialogState extends ConsumerState<EventInputDialog> {
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _organizerController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  final dateFormat = DateFormat("EEE, MMM d • hh:mm a");

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startDateTime = dateTime;
      } else {
        _endDateTime = dateTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Event"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(labelText: "Venue"),
            ),
            TextField(
              controller: _organizerController,
              decoration: const InputDecoration(labelText: "Organizer"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(_startDateTime == null
                      ? "Start Date: Not set"
                      : "Start: ${dateFormat.format(_startDateTime!)}"),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDateTime(true),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(_endDateTime == null
                      ? "End Date: Not set"
                      : "End: ${dateFormat.format(_endDateTime!)}"),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDateTime(false),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty ||
                _venueController.text.isEmpty ||
                _descriptionController.text.isEmpty ||
                _organizerController.text.isEmpty ||
                _startDateTime == null ||
                _endDateTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please fill all fields")),
              );
              return;
            }

            
            final newEvent = Event(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descriptionController.text,
              venue: _venueController.text,
              startDateTime: _startDateTime!,
              endDateTime: _endDateTime!,
              organizerName: _organizerController.text,
            );

            ref.read(eventsProvider.notifier).createTheEvent(newEvent);
            Navigator.of(context).pop(newEvent); // return event
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
