import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ViewModel.dart';
import 'UIState.dart';

// Provider for UserState and UserViewModel
final userViewModelProvider = StateNotifierProvider<UserViewModel, UserState>(
      (ref) => UserViewModel(),
);
