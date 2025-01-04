import 'package:flutter/material.dart';
import 'Model.dart';
import 'login.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  SubscribePageState createState() => SubscribePageState();
}

class SubscribePageState extends State<SubscribePage> {
  bool isLoggedIn = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text;
      final password = passwordController.text;

      // Create a new user
      final newUser = User(email: email, password: password);

      // save to database
      //final apiService = locator<ApiService>();

      try {
        //await apiService.postUsers([newUser]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registracija je bila uspešna!")),
        );
        // Navigate to the Login page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prišlo je do napake: $e')),
        );
      }

      // Simulate saving to a database
      //localUsersList.add(newUser);
      //await saveUsersList(localUsersList);

    }
  }


  @override
  Widget build(BuildContext context) {
    // parameters
    var contextSizeHeight = MediaQuery.of(context).size.height;
    var contextSizeWidth = MediaQuery.of(context).size.width;

    // design
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
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "E-posta",
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              prefixIcon: Icon(Icons.mail, color: Color(0xff212435)),
                              border: UnderlineInputBorder(),
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
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Geslo",
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              prefixIcon: Icon(Icons.lock, color: Color(0xff212435)),
                              border: UnderlineInputBorder(),
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
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Potrditev Gesla",
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              prefixIcon: Icon(Icons.lock, color: Color(0xff212435)),
                              border: UnderlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != passwordController.text) {
                                return 'Gesli se ne ujemata.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          MaterialButton(
                            onPressed: registerUser,
                            color: const Color(0xff3a57e8),
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
                          const SizedBox(height: 8),
                        Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const Login()),
                                    );
                                  },
                                  child: const Text(
                                    "Nazaj na vpis?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff5e5e5e),
                                    ),
                                  ),
                                ),
                              ],
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
