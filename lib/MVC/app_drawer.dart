import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppDrawer extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;

  const AppDrawer({
    Key? key,
    required this.isDarkTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _quote = "Loading...";
  String _author = "";

  @override
  void initState() {
    super.initState();
    _fetchQuoteOfTheDay();
  }

  void _fetchQuoteOfTheDay() async {
    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));  // API HERE

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quote = data[0]['q'] ?? "No quote available.";
          _author = data[0]['a'] ?? "Unknown Author";
        });
      } else {
        throw Exception('Failed to fetch quote');
      }
    } catch (e) {
      print("Error fetching quote: $e");
      setState(() {
        _quote = "The best way to predict the future is to create it.";
        _author = "Peter Drucker";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'egzon@gmail.com',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  '"$_quote"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "- $_author",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Toggle Dark Theme'),
            onTap: () {
              widget.onThemeChanged(!widget.isDarkTheme);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              // Add Change Password functionality
            },
          ),
        ],
      ),
    );
  }
}
