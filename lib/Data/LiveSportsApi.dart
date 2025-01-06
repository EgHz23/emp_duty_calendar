import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http;
import '../MVC/Model.dart';
import 'DataBase.dart'; // For making HTTP requests

Future<List<Event>> fetchLiveSportEvents() async {
  const url = 'https://live-sports-data-events-api.p.rapidapi.com/tracker';

  const headers = {
    'Content-Type': 'application/json',
    'x-rapidapi-host': 'live-sports-data-events-api.p.rapidapi.com',
    'x-rapidapi-key': '09018b7d68mshfa34ed661bb0145p10e87fjsn2d0d36573f8d', // Place your API key here
  };

  // Request body (adjust as necessary based on your API)
  final body = jsonEncode({
    'opName': 'GetLiveEvents',
    'SportId': 1,
  });

  try {
    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Parse the response JSON
      final data = jsonDecode(response.body);
      final eventsData = data['responseInfo']; // Assuming the events are in 'responseInfo'

      if (eventsData != null) {
        // Iterate over the list of events and create Event objects
        for (var eventData in eventsData) {
          final event = Event(
            eventName: eventData['cgn'] ?? 'Unknown Event',
            eventDescription: eventData['esc'] ?? 'No description available',
            eventTime: DateTime.fromMillisecondsSinceEpoch(eventData['ste']),
          );
          liveSportEvents.add(event);
        }
      } else {
        print('No events found.');
      }
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }

  // Return the list of events
  return liveSportEvents;
}