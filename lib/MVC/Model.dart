import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Represents an event with name, description, and time
class Event {
  final String eventName;
  final String eventDescription;
  final DateTime eventTime;

  Event({
    required this.eventName,
    required this.eventTime,
    required this.eventDescription,
  });

  /// Serialize an Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'eventTime': eventTime.toIso8601String(), // Convert DateTime to ISO 8601 format string
      'eventDescription': eventDescription,
    };
  }

  /// Deserialize an Event from JSON with validation
  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing JSON: $json"); // Debug log for incoming JSON

      // Extract fields from the JSON
      final eventName = json['name'] as String?;
      final eventDescription = json['description'] as String?;
      final eventTime = json['date'] as String?;

      // Validate required fields
      if (eventName == null || eventTime == null) {
        throw Exception("Invalid data: Missing required fields. JSON: $json");
      }

      return Event(
        eventName: eventName,
        eventDescription: eventDescription ?? 'No description available',
        eventTime: DateTime.parse(eventTime),
      );
    } catch (e) {
      print("Error parsing event: $e");
      // Return a fallback Event object for invalid data
      return Event(
        eventName: 'Invalid Event',
        eventDescription: 'Error while parsing',
        eventTime: DateTime.now(),
      );
    }
  }

  @override
  String toString() {
    return 'Event(eventName: $eventName, eventDescription: $eventDescription, eventTime: $eventTime)';
  }
}

/// Utility to get the holidays file path
Future<File> getHolidaysFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/holidays.json');
}

/// Load holidays from the local file
Future<List<Event>> loadHolidays() async {
  try {
    final file = await getHolidaysFile();
    if (!await file.exists()) {
      print("Holidays file does not exist. Returning empty list.");
      return []; // Return an empty list if the file doesn't exist
    }

    String contents = await file.readAsString();
    if (contents.isEmpty) {
      print("Holidays file is empty. Returning empty list.");
      return []; // Return an empty list if the file is empty
    }

    List<dynamic> jsonList = jsonDecode(contents);
    List<Event> holidays = jsonList.map((item) {
      return Event.fromJson(item as Map<String, dynamic>);
    }).toList();

    print("Holidays loaded successfully: $holidays");
    return holidays;
  } catch (e) {
    print("Error loading holidays: $e");
    return []; // Return an empty list if there's an error
  }
}

/// Save holidays to the local file
Future<bool> saveHolidays(List<Event> holidays) async {
  try {
    final file = await getHolidaysFile();
    List<Map<String, dynamic>> jsonList = holidays.map((event) => event.toJson()).toList();
    String holidaysJson = jsonEncode(jsonList);

    await file.writeAsString(holidaysJson);
    print("Holidays saved successfully to ${file.path}");
    return true;
  } catch (e) {
    print("Error saving holidays: $e");
    return false;
  }
}

/// Represents a user with events
class User {
  final String email;
  final String password;
  List<Event> activeEventList;
  List<Event> expiredEventList;

  User({
    required this.email,
    required this.password,
    List<Event>? activeEventList,
    List<Event>? expiredEventList,
  })  : activeEventList = activeEventList ?? [],
        expiredEventList = expiredEventList ?? [];

  /// Serialize a User to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'activeEventList': activeEventList.map((event) => event.toJson()).toList(),
      'expiredEventList': expiredEventList.map((event) => event.toJson()).toList(),
    };
  }

  /// Deserialize a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      final activeEventList = (json['activeEventList'] as List<dynamic>?)
              ?.map((item) => Event.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final expiredEventList = (json['expiredEventList'] as List<dynamic>?)
              ?.map((item) => Event.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      return User(
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        activeEventList: activeEventList,
        expiredEventList: expiredEventList,
      );
    } catch (e) {
      print("Error parsing user: $e");
      return User(email: 'Invalid User', password: '');
    }
  }

  @override
  String toString() {
    return 'User(email: $email, activeEventList: $activeEventList, expiredEventList: $expiredEventList)';
  }
}

/// Utility to get the user file path
Future<File> getUserFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/user.json');
}

/// Load a user from the local file
Future<User?> loadUser() async {
  try {
    final file = await getUserFile();
    if (!await file.exists()) {
      return null; // Return null if the file doesn't exist
    }

    String contents = await file.readAsString();
    final Map<String, dynamic> userMap = jsonDecode(contents);

    print("User loaded successfully: $userMap");
    return User.fromJson(userMap);
  } catch (e) {
    print("Error loading user: $e");
    return null; // Return null if there's an error
  }
}

/// Save a user to the local file
Future<bool> saveUser(User user) async {
  try {
    final file = await getUserFile();
    String userJson = jsonEncode(user.toJson());

    await file.writeAsString(userJson);
    print("User ${user.email} saved successfully to ${file.path}");
    return true;
  } catch (e) {
    print("Error saving user: $e");
    return false;
  }
}
