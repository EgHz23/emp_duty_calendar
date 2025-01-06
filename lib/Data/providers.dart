import 'package:flutter_riverpod/flutter_riverpod.dart';

// A provider to store the currently logged-in user's email
final currentUserProvider = StateProvider<String?>((ref) => null);
