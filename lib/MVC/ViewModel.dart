import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Model.dart';
import 'UIState.dart';

class UserViewModel extends StateNotifier<UserState> {
  UserViewModel() : super(UserState.initial());

  // Add event to active event list
  void addEvent(Event event) {
    final updatedEvents = List<Event>.from(state.activeEventList)..add(event);
    state = state.copyWith(activeEventList: updatedEvents);
  }

  // Edit an existing event
  void editEvent(int index, Event updatedEvent) {
    final updatedEvents = List<Event>.from(state.activeEventList);
    updatedEvents[index] = updatedEvent;
    state = state.copyWith(activeEventList: updatedEvents);
  }

  // Remove event from active list
  void deleteEvent(int index) {
    final updatedEvents = List<Event>.from(state.activeEventList)..removeAt(index);
    state = state.copyWith(activeEventList: updatedEvents);
  }

  // Update expired events (to move events from active to expired if their time has passed)
  void updateExpiredEvents(DateTime currentDate) {
    final activeEvents = state.activeEventList.where((event) => event.eventTime.isAfter(currentDate)).toList();
    final expiredEvents = state.activeEventList.where((event) => event.eventTime.isBefore(currentDate)).toList();

    state = state.copyWith(
      activeEventList: activeEvents,
      expiredEventList: expiredEvents,
    );
  }

  // Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // Set error state
  void setError(String error) {
    state = state.copyWith(error: error);
  }
}
