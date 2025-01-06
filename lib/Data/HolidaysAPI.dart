import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Data/database_helper.dart';
import '../MVC/Model.dart';

Future<List<Event>> fetchPublicHolidaysForCurrentYear() async {
  final currentYear = DateTime.now().year;
  final url = 'https://public-holidays7.p.rapidapi.com/$currentYear/SI';

  const headers = {
    'x-rapidapi-host': 'public-holidays7.p.rapidapi.com',
    'x-rapidapi-key': '09018b7d68mshfa34ed661bb0145p10e87fjsn2d0d36573f8d', 
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      List<Event> events = data.map((json) => Event.fromJson(json)).toList();
      print("Fetched Holidays: ${events.map((e) => e.eventName).join(', ')}");

      // Save holidays to the database
      for (var event in events) {
        final formattedDate = event.eventTime.toIso8601String().split('T')[0];
        await DatabaseHelper.instance.insertEvent({
          'date': formattedDate,
          'name': event.eventName,
          'time': '00:00', 
          'group_id': null,
          'location_id': null, 
          'is_holiday': 1, 
        });
      }

      return events;
    } else {
      print("Failed to fetch holidays. Status Code: ${response.statusCode}");
      print("Response: ${response.body}");
      return [];
    }
  } catch (e) {
    print("Error fetching holidays: $e");
    return [];
  }
}
