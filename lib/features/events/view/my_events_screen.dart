import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';
import 'package:campus_event_mgmt_system/features/events/view/event_detail_screen.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';
import 'package:intl/intl.dart';

class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterSection(ref, eventsAsync),
          _buildEventsList(ref, eventsAsync),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('My Events', style: kTextStyle(size: 20, isBold: true)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.green[50],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event_available,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Registered Events',
                  style: kTextStyle(size: 16, isBold: true),
                ),
                Text(
                  'Track your upcoming and past events',
                  style: kTextStyle(size: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(WidgetRef ref, AsyncValue<List<Event>> eventsAsync) {
    final currentFilter = ref.watch(eventFilterProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterHeader(eventsAsync),
          const SizedBox(height: 12),
          _buildFilterChips(ref, currentFilter),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(AsyncValue<List<Event>> eventsAsync) {
    return Row(
      children: [
        Text('Filter My Events', style: kTextStyle(size: 16, isBold: true)),
        const Spacer(),
        eventsAsync.when(
          data: (events) => Text(
            '${events.length} events',
            style: kTextStyle(size: 12, color: Colors.grey[600]),
          ),
          loading: () => Text(
            'Loading...',
            style: kTextStyle(size: 12, color: Colors.grey[600]),
          ),
          error: (_, __) => Text(
            'Error',
            style: kTextStyle(size: 12, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(WidgetRef ref, EventFilter currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: EventFilter.values.map((filter) {
          final isSelected = currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                _getFilterLabel(filter),
                style: kTextStyle(
                  size: 14,
                  isBold: isSelected,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(eventFilterProvider.notifier).state = filter;
                }
              },
              backgroundColor: Colors.grey[100],
              selectedColor: _getFilterColor(filter),
              checkmarkColor: Colors.white,
              elevation: isSelected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventsList(WidgetRef ref, AsyncValue<List<Event>> eventsAsync) {
    return Expanded(
      child: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _buildEmptyState(ref.watch(eventFilterProvider));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(eventsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _buildMyEventCard(context, events[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(),
      ),
    );
  }

  Widget _buildMyEventCard(BuildContext context, Event event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleEventTap(context, event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: kTextStyle(size: 18, isBold: true),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(event),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: kTextStyle(size: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildEventDetails(event),
              const SizedBox(height: 12),
              _buildRegistrationInfo(event),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Event event) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (event.isPast) {
      badgeColor = Colors.grey;
      statusText = 'Completed';
      statusIcon = Icons.check_circle;
    } else if (event.isOngoing) {
      badgeColor = Colors.green;
      statusText = 'Live Now';
      statusIcon = Icons.live_tv;
    } else {
      badgeColor = Colors.blue;
      statusText = 'Upcoming';
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: kTextStyle(size: 10, isBold: true, color: badgeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(Event event) {
    return Row(
      children: [
        _buildDetailItem(
          Icons.calendar_today,
          DateFormat('MMM dd, yyyy').format(event.dateTime),
        ),
        const SizedBox(width: 16),
        _buildDetailItem(
          Icons.access_time,
          DateFormat('hh:mm a').format(event.dateTime),
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
          Icon(icon, size: 14, color: Colors.grey[600]),
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

  Widget _buildRegistrationInfo(Event event) {
    return Row(
      children: [
        Expanded(
          child: Text(
            event.organizerName,
            style: kTextStyle(size: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people, size: 12, color: Colors.green[700]),
              const SizedBox(width: 4),
              Text(
                '${event.registeredUsers} registered',
                style: kTextStyle(size: 10, isBold: true, color: Colors.green[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(EventFilter filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyStateIcon(filter),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateTitle(filter),
            style: kTextStyle(size: 18, isBold: true),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(filter),
            style: kTextStyle(size: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Something went wrong', style: kTextStyle(size: 18, isBold: true)),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: kTextStyle(size: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _handleEventTap(BuildContext context, Event event) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => EventDetailScreen(event: event),
    ));
  }

  // Helper methods
  String _getFilterLabel(EventFilter filter) {
    return switch (filter) {
      EventFilter.upcoming => 'Upcoming',
      EventFilter.ongoing => 'Ongoing',
      EventFilter.past => 'Completed',
    };
  }

  Color _getFilterColor(EventFilter filter) {
    return switch (filter) {
      EventFilter.upcoming => Colors.blue,
      EventFilter.ongoing => Colors.green,
      EventFilter.past => Colors.grey,
    };
  }

  IconData _getEmptyStateIcon(EventFilter filter) {
    return switch (filter) {
      EventFilter.upcoming => Icons.event_busy,
      EventFilter.ongoing => Icons.event_note,
      EventFilter.past => Icons.history,
    };
  }

  String _getEmptyStateTitle(EventFilter filter) {
    return switch (filter) {
      EventFilter.upcoming => 'No Upcoming Events',
      EventFilter.ongoing => 'No Ongoing Events',
      EventFilter.past => 'No Completed Events',
    };
  }

  String _getEmptyStateMessage(EventFilter filter) {
    return switch (filter) {
      EventFilter.upcoming => 'You haven\'t registered for any upcoming events yet.\nBrowse events to get started!',
      EventFilter.ongoing => 'No events are currently happening.\nCheck your upcoming events!',
      EventFilter.past => 'You haven\'t attended any events yet.\nRegister for events to build your history!',
    };
  }
}
