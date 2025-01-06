import 'package:flutter/material.dart';
import '../Data/database_helper.dart';
import 'login.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  SubscribePageState createState() => SubscribePageState();
}

class SubscribePageState extends State<SubscribePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      try {
        // Check if the email already exists
        final emailAlreadyExists = await DatabaseHelper.instance.emailExists(email);
        if (emailAlreadyExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("E-poštni naslov je že registriran.")),
          );
          return;
        }

        // Register the user in the database
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Napaka pri registraciji: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double contextSizeHeight = MediaQuery.of(context).size.height;
    final double contextSizeWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: contextSizeHeight,
        width: contextSizeWidth,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Image.network(
              "https://svet.fri.uni-lj.si/wp-content/uploads/2017/01/fri.jpg",
              height: contextSizeHeight * 0.4,
              width: contextSizeWidth,
              fit: BoxFit.contain,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: contextSizeHeight * 0.65,
                width: contextSizeWidth,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Registracija",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "E-pošta",
                              prefixIcon: Icon(Icons.mail, color: Colors.blueAccent),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Prosimo vnesite e-pošto.';
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Vnesite veljaven e-poštni naslov.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Geslo",
                              prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Prosimo vnesite geslo.';
                              } else if (value.length < 8) {
                                return 'Geslo mora biti dolgo vsaj 8 znakov.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Potrditev Gesla",
                              prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != passwordController.text) {
                                return 'Gesli se ne ujemata.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          MaterialButton(
                            onPressed: registerUser,
                            color: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(16),
                            minWidth: contextSizeWidth,
                            child: const Text(
                              "Registriraj",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                );
                              },
                              child: const Text(
                                "Nazaj na vpis?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
