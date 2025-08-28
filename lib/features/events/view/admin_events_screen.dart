

import 'package:campus_event_mgmt_system/core/widgets/custom-alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';
import 'package:campus_event_mgmt_system/features/events/view/event_detail_screen.dart';
import 'package:campus_event_mgmt_system/features/profile/view/profile_screen.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(filteredEventsProvider); // ✅ use filtered provider

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildAdminHeader(),
          _buildFilterSection(ref, eventsAsync),
          _buildEventsList(ref, eventsAsync),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Admin Dashboard', style: kTextStyle(size: 20, isBold: true)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Panel', style: kTextStyle(size: 16, isBold: true)),
                Text(
                  'Manage all campus events',
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
        Text('Filter Events', style: kTextStyle(size: 16, isBold: true)),
        const Spacer(),
        eventsAsync.when(
          data: (events) => Text(
            '${events.length} events',
            style: kTextStyle(size: 12, color: Colors.grey[600]),
          ),
          loading: () => Text('Loading...', style: kTextStyle(size: 12, color: Colors.grey[600])),
          error: (_, __) => Text('Error', style: kTextStyle(size: 12, color: Colors.red)),
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
              ref.invalidate(eventsProvider); // ✅ still refreshes main source
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _buildAdminEventCard(context, ref, events[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(),
      ),
    );
  }

  Widget _buildAdminEventCard(BuildContext context, WidgetRef ref, Event event) {
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
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleEventAction(context, ref, event, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
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
              _buildAdminStats(event),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetails(Event event) {
    return Row(
      children: [
        _buildDetailItem(Icons.calendar_today, _formatDateTime(event.startDateTime)),
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

  Widget _buildAdminStats(Event event) {
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
        ),
      ],
    );
  }

  Widget _buildEmptyState(EventFilter filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getEmptyStateIcon(filter), size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_getEmptyStateTitle(filter), style: kTextStyle(size: 18, isBold: true)),
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
          Text('Please try again later', style: kTextStyle(size: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _handleCreateEvent(context),
      backgroundColor: Colors.blue[700],
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // Actions
  void _handleEventTap(BuildContext context, Event event) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => EventDetailScreen(event: event),
    ));
  }

  void _handleCreateEvent(BuildContext context) {
    _showEventDialog(context);
  }

  void _handleEventAction(BuildContext context, WidgetRef ref, Event event, String action) {
    switch (action) {
      case 'edit':
        _showEventDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, event);
        break;
    }
  }

  // TODOs kept same as before...
  void _showEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EventInputDialog(context: context,),
    );
  }
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Event event) {

  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Helpers
  String _getFilterLabel(EventFilter filter) => switch (filter) {
        EventFilter.upcoming => 'Upcoming',
        EventFilter.ongoing => 'Ongoing',
        EventFilter.past => 'Past',
      };

  Color _getFilterColor(EventFilter filter) => switch (filter) {
        EventFilter.upcoming => Colors.blue,
        EventFilter.ongoing => Colors.green,
        EventFilter.past => Colors.grey,
      };

  IconData _getEmptyStateIcon(EventFilter filter) => switch (filter) {
        EventFilter.upcoming => Icons.event_busy,
        EventFilter.ongoing => Icons.event_note,
        EventFilter.past => Icons.history,
      };

  String _getEmptyStateTitle(EventFilter filter) => switch (filter) {
        EventFilter.upcoming => 'No Upcoming Events',
        EventFilter.ongoing => 'No Ongoing Events',
        EventFilter.past => 'No Past Events',
      };

  String _getEmptyStateMessage(EventFilter filter) => switch (filter) {
        EventFilter.upcoming => 'Create your first event to get started!',
        EventFilter.ongoing => 'No events are currently happening.\nCheck upcoming events instead!',
        EventFilter.past => 'No past events to show.\nCheck upcoming events instead!',
      };
}
