import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Event {
  final String eventName;
  final String eventDescription;
  final DateTime eventTime;

  Event({required this.eventName, required this.eventTime, required this.eventDescription});

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'eventTime': eventTime.toIso8601String(), // Convert DateTime to ISO 8601 format string
      'eventDescription': eventDescription,
    };
  }

  // Deserialization
  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        eventName: json['eventName'] ?? '', // Default to empty string if null
        eventDescription: json['eventDescription'] ?? '', // Default to empty string if null
        eventTime: DateTime.parse(json['eventTime'] ?? ''), // Use empty string to trigger a parse error if invalid
      );
    } catch (e) {
      print("Error parsing event: $e");
      // Handle case where parsing fails (return a default event or null)
      return Event(eventName: '', eventDescription: '', eventTime: DateTime.now());
    }
  }
}

// Function to get holidays file path
Future<File> getHolidaysFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/holidays.json');
}

// Load holidays from file
Future<List<Event>> loadHolidays() async {
  try {
    final file = await getHolidaysFile();
    if (!await file.exists()) {
      return [];  // Return an empty list if file doesn't exist
    }

    String contents = await file.readAsString();
    print("File contents: $contents");
    if (contents.isEmpty) {
      return [];  // Return an empty list if file is empty
    }

    List<dynamic> jsonList = jsonDecode(contents);
    List<Event> holidays = jsonList.map((item) => Event.fromJson(item as Map<String, dynamic>)).toList();

    print("Holidays loaded successfully from ${file.path}");
    return holidays;
  } catch (e) {
    print("Error loading holidays: $e");
    return [];  // Return an empty list in case of an error
  }
}

// Save holidays to file
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

// User class
class User {
  final String email;
  final String password;
  List<Event> activeEventList = [];
  List<Event> expiredEventList = [];

  User({required this.email, required this.password, List<Event>? activeEventList, List<Event>? expiredEventList}) {
    if (activeEventList != null) {
      this.activeEventList = activeEventList;
    }
    if (expiredEventList != null) {
      this.expiredEventList = expiredEventList;
    }
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'activeEventList': activeEventList.map((event) => event.toJson()).toList(),
      'expiredEventList': expiredEventList.map((event) => event.toJson()).toList(),
    };
  }

  // Deserialization
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
      activeEventList: (json['activeEventList'] as List<dynamic>)
          .map((item) => Event.fromJson(item as Map<String, dynamic>))
          .toList(),
      expiredEventList: (json['expiredEventList'] as List<dynamic>)
          .map((item) => Event.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Get the file in the app's documents directory
Future<File> getUserFile() async {
  final directory = await getApplicationDocumentsDirectory(); // Platform-specific documents directory
  return File('${directory.path}/user.json'); // Save/load 'user.json'
}

// Load user from file
Future<User?> loadUser() async {
  try {
    final file = await getUserFile(); // Get the file from documents directory

    if (!await file.exists()) {
      return null; // Return null if the file doesn't exist
    }

    String contents = await file.readAsString(); // Read the file contents

    // Decode the JSON into a map and convert it to a User object
    final Map<String, dynamic> userMap = jsonDecode(contents);
    print("User loaded successfully to ${file.path}");
    return User.fromJson(userMap); // Assuming User.fromJson is implemented
  } catch (e) {
    print("Error loading user: $e");
    return null; // Return null if there's an error
  }
}

// Save user to file
Future<bool> saveUser(User user) async {
  try {
    final file = await getUserFile(); // Get the file from documents directory

    String userJson = jsonEncode(user.toJson()); // Convert the user object to JSON
    await file.writeAsString(userJson); // Write JSON to the file

    print("User ${user.email}saved successfully to ${file.path}");
    return true;
  } catch (e) {
    print("Error saving user: $e");
    return false;
  }
}


