import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    color: Colors.black87,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.tealAccent,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  cardColor: Colors.grey[850],
  dialogBackgroundColor: Colors.grey[800],
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey,
    hintStyle: TextStyle(color: Colors.white54),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.tealAccent),
);
