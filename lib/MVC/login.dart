import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Data/database_helper.dart';
import 'home.dart';
import 'subscribePage.dart';
import '../Data/providers.dart';
// StateProvider to handle the "Zapomni se me" checkbox state
final rememberMeProvider = StateProvider<bool>((ref) => false);
final emailProvider = StateProvider<String>((ref) => "");
final passwordProvider = StateProvider<String>((ref) => "");

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeRememberedCredentials();
  }

  void _initializeRememberedCredentials() {
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);

    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        emailController.text = email;
        passwordController.text = password;
        ref.read(rememberMeProvider.notifier).state = true;
      });
    }
  }

  Future<void> loginUser() async {
  if (_formKey.currentState!.validate()) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final user = await DatabaseHelper.instance.loginUser(email, password);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );

        // Save credentials if "Remember Me" is checked
        if (ref.read(rememberMeProvider)) {
          ref.read(emailProvider.notifier).state = email;
          ref.read(passwordProvider.notifier).state = password;
        } else {
          ref.read(emailProvider.notifier).state = "";
          ref.read(passwordProvider.notifier).state = "";
        }

        // Update the currentUserProvider with the logged-in email
        ref.read(currentUserProvider.notifier).state = email;

        // Navigate to the Home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during login: $e")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final rememberMe = ref.watch(rememberMeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Image.network(
              "https://svet.fri.uni-lj.si/wp-content/uploads/2017/01/fri.jpg",
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Dobrodošli v EMP-Calendar",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Prosim prijavite se za nadaljevanje",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff5e5e5e),
                            ),
                          ),
                          const SizedBox(height: 30),
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
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              const Text("Zapomni se me"),
                              Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  ref.read(rememberMeProvider.notifier).state = value ?? false;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          MaterialButton(
                            onPressed: loginUser,
                            color: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(16),
                            minWidth: MediaQuery.of(context).size.width,
                            child: const Text(
                              "Vpis",
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
                                  MaterialPageRoute(builder: (context) => const SubscribePage()),
                                );
                              },
                              child: const Text(
                                "Registracija?",
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
