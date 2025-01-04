import 'Model.dart';

class UserState {
  final bool isLoading;
  final bool isLoggedIn;
  final User? user;
  final String? error;
  final List<Event> activeEventList;
  final List<Event> expiredEventList;

  UserState({
    required this.isLoggedIn,
    required this.isLoading,
    this.user,
    this.error,
    required this.activeEventList,
    required this.expiredEventList,
  });

  factory UserState.initial() {
    return UserState(
      isLoggedIn: false,
      isLoading: false,
      user: null,
      error: null,
      activeEventList: [],
      expiredEventList: [],
    );
  }

  UserState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    User? user,
    String? error,
    List<Event>? activeEventList,
    List<Event>? expiredEventList,
  }) {
    return UserState(
      isLoggedIn: isLoggedIn ?? this.isLoading,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      activeEventList: activeEventList ?? this.activeEventList,
      expiredEventList: expiredEventList ?? this.expiredEventList,
    );
  }
}