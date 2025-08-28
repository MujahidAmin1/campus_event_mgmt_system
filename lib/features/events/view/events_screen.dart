import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_mgmt_system/models/event.dart';
import 'package:campus_event_mgmt_system/features/events/controller/event_controller.dart';
import 'package:campus_event_mgmt_system/features/events/view/event_card.dart';
import 'package:campus_event_mgmt_system/features/events/view/event_detail_screen.dart';
import 'package:campus_event_mgmt_system/features/events/view/my_events_screen.dart';
import 'package:campus_event_mgmt_system/features/profile/view/profile_screen.dart';
import 'package:campus_event_mgmt_system/core/utils/kTextStyle.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final eventsAsync = ref.watch(filteredEventsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterSection(ref, eventsAsync),
          _buildEventsList(ref, eventsAsync),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return AppBar(
      title: Text('Campus Events', style: kTextStyle(size: 20, isBold: true)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.event_available),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => MyEventsScreen(userId: auth.currentUser!.uid,),
            ));
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search
          },
        ),
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
                return EventCard(
                  event: events[index],
                  onTap: () => _handleEventTap(context, events[index]),
                  onRegister: () => _handleRegister(context, ref ,events[index], FirebaseAuth.instance.currentUser!.uid),
                  isRegistered: true,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(),
      ),
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

  Widget _buildFAB(BuildContext context) {
    // Students cannot create events, so no FAB needed
    return const SizedBox.shrink();
  }

  void _handleEventTap(BuildContext context, Event event) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => EventDetailScreen(event: event),
    ));
  }

 void _handleRegister(BuildContext context, WidgetRef ref, Event event, String userId) async {
  try {
    // Call controller registration
    await ref.read(eventsProvider.notifier).registerForEvent(userId, event);

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully registered for ${event.title}')),
    );
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to register: $e')),
    );
  }
}

  // Helpers
  String _getFilterLabel(EventFilter filter) {
    return switch (filter) {
      EventFilter.upcoming => 'Upcoming',
      EventFilter.ongoing => 'Ongoing',
      EventFilter.past => 'Past',
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
      EventFilter.past => 'No Past Events',
    };
  }

  String _getEmptyStateMessage(EventFilter filter) {
    return switch (filter) {
      EventFilter.upcoming => 'Check back later for new events\nor create one yourself!',
      EventFilter.ongoing => 'No events are currently happening.\nCheck upcoming events instead!',
      EventFilter.past => 'No past events to show.\nCheck upcoming events instead!',
    };
  }
}
