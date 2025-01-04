import 'dart:convert';
import 'package:http/http.dart' as http;

import '../MVC/Model.dart';

Future<List<Event>> fetchPublicHolidaysForCurrentYear() async {
  // Get the current year dynamically
  final currentYear = DateTime.now().year;

  // Define the URL for public holidays in Slovenia (SI) for the current year
  final url = 'https://public-holidays7.p.rapidapi.com/$currentYear/SI';

  // Define the necessary headers for the request
  const headers = {
    'x-rapidapi-host': 'public-holidays7.p.rapidapi.com',
    'x-rapidapi-key': '09018b7d68mshfa34ed661bb0145p10e87fjsn2d0d36573f8d', // Replace with your actual API key from RapidAPI
  };

  try {
    // Send GET request to the API with the headers
    final response = await http.get(Uri.parse(url), headers: headers);

    // Check the response status
    if (response.statusCode == 200) {
      // If the request is successful, parse the response body
      final List<dynamic> data = jsonDecode(response.body);

      // Convert the list of JSON objects into a List of Event objects
      List<Event> events = data.map((json) => Event.fromJson(json)).toList();
      print("Fetched Holidays: ${events.map((e) => e.eventName).join(', ')}");
      return events;
    } else {
      // If the response is not successful, print the error details
      print("Failed to fetch holidays. Status Code: ${response.statusCode}");
      print("Response: ${response.body}");
      return [];
    }
  } catch (e) {
    // Catch and print any errors during the request
    print("Error fetching holidays: $e");
    return [];
  }
}

