import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Data/DataBase.dart';
import 'Data/database_helper.dart';
import 'Data/HolidaysAPI.dart';
import 'MVC/Model.dart';
import 'MVC/login.dart';

// StateProvider for managing theme state
final themeProvider = StateProvider<bool>((ref) => false);

// Function to insert initial data
Future<void> insertInitialData() async {
  final dbHelper = DatabaseHelper.instance;

  // Insert Groups
  final groups = [
    {'name': 'DevOps'},
    {'name': 'Software'},
    {'name': 'Network'},
    {'name': 'Security'},
    {'name': 'DC'},
  ];

  for (var group in groups) {
    await dbHelper.insertGroup(group);
  }

  // Insert Locations
  final locations = [
    {'name': 'Sejna soba 100', 'address': 'Building A'},
    {'name': 'Sejna soba 200', 'address': 'Building B'},
    {'name': 'Sejna soba 300', 'address': 'Building C'},
    {'name': 'Zunanji objekt', 'address': 'Outdoor Facility'},
  ];

  for (var location in locations) {
    await dbHelper.insertLocation(location);
  }

  print("Initial data inserted: Groups and Locations");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Insert initial data for groups and locations
  await insertInitialData();

  // Load holidays -> either from local file or API (if not in local file)
  yearlyHolidays = await loadHolidays();
  if (yearlyHolidays.isEmpty) {
    print("No holidays found in local storage, fetching from API...");
    yearlyHolidays = await fetchPublicHolidaysForCurrentYear();
    if (yearlyHolidays.isNotEmpty) {
      await saveHolidays(yearlyHolidays);
    }
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme state
    final isDarkTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const Login(),
    );
  }
}
