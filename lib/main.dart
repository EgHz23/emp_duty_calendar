import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Data/DataBase.dart';
import 'Data/HolidaysAPI.dart';
import 'MVC/Model.dart';
import 'MVC/StateNotifier.dart';
import 'MVC/login.dart';

// Provider to manage the app theme
/*
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
      (ref) => ThemeNotifier(),
);*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load holidays -> either from local file or API(if not in local file)
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
    //final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData.light(), // Define your light theme here
      darkTheme: ThemeData.dark(), // Define your dark theme here
      //themeMode: themeMode, // Dynamically changes theme based on provider
      home: const Login(),
    );
  }
}
