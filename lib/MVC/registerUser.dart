import 'package:flutter/material.dart';
import '../Data/database_helper.dart';
import 'login.dart';

Future<void> registerUser(BuildContext context, GlobalKey<FormState> formKey,
    TextEditingController emailController, TextEditingController passwordController) async {
  if (formKey.currentState!.validate()) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // Check if email already exists
      final emailAlreadyExists = await DatabaseHelper.instance.emailExists(email);
      if (emailAlreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("E-poštni naslov je že registriran.")),
        );
        return;
      }

      // Register the user
      await DatabaseHelper.instance.registerUser(email, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registracija je bila uspešna!")),
      );

      // Navigate to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      // Handle any errors during registration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Napaka pri registraciji: $e")),
      );
    }
  }
}
