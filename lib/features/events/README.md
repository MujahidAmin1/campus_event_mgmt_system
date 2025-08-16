# Events Feature

This feature implements a modern and simplistic UI for campus event management with filtering capabilities.

## Structure

```
lib/features/events/
├── controller/
│   └── event_controller.dart      # Riverpod providers and state management
├── repository/
│   └── event_repository.dart      # Data layer and API calls
├── view/
│   ├── events_screen.dart         # Main events screen with filter chips
│   └── event_card.dart           # Reusable event card widget
└── README.md                     # This file
```

## Features

### Filter Chips
- **Upcoming**: Shows events that haven't started yet
- **Ongoing**: Shows events currently in progress
- **Past**: Shows completed events

### UI Components
- Modern card-based design
- Pull-to-refresh functionality
- Empty states for each filter
- Loading and error states
- Event count display
- Search and filter buttons (placeholders)

### State Management
- Uses Riverpod for state management
- Separate providers for different concerns:
  - `eventRepositoryProvider`: Repository instance
  - `eventFilterProvider`: Current filter state
  - `currentFilteredEventsProvider`: Filtered events based on current filter
  - `eventControllerProvider`: Controller for business logic

## Usage

The events screen is automatically loaded when the app starts. Users can:

1. **Switch between filters** by tapping the filter chips
2. **View event details** by tapping on event cards
3. **Refresh the list** by pulling down
4. **Create new events** using the floating action button

## TODO Items

The following functionality is left as placeholders for future implementation:

### Repository Layer
- [ ] Implement actual API calls
- [ ] Add local database support
- [ ] Add caching mechanisms
- [ ] Implement real-time updates

### UI Features
- [ ] Search functionality
- [ ] Additional filters (category, location, etc.)
- [ ] Event details screen
- [ ] Create/edit event screens
- [ ] Event registration functionality

### Business Logic
- [ ] User authentication
- [ ] Event permissions
- [ ] Notification system
- [ ] Analytics tracking

## Dependencies

- `flutter_riverpod`: State management
- `intl`: Date formatting

## Models

The feature uses the `Event` model with the following properties:
- Basic info (title, description, location)
- Date/time (startDate, endDate)
- Status (upcoming, ongoing, past)
- Organizer and participant info
- Categories and pricing

