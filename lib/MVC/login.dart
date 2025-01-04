import 'package:emp_duty_calendar/MVC/subscribePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Model.dart';
import 'home.dart';

final checkProvider = StateProvider<bool>((ref) => true);
final filteredUsersProvider = StateProvider<List<String>>((ref) => []);
User? localUserData; // Global variable to store the user data

Future<void> _loadLocalUserData() async {
  localUserData = await loadUser();
}

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData(); // Call the initialization method
  }

  Future<void> _initializeData() async {
    await _loadLocalUserData(); // Load user data asynchronously
    if (localUserData != null) {
      setState(() {
        emailController.text = localUserData!.email;
        passwordController.text = localUserData!.password;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsersList = ref.watch(filteredUsersProvider);
    final isChecked = ref.watch(checkProvider);

    var contextSizeHeight = MediaQuery.of(context).size.height;
    var contextSizeWidth = MediaQuery.of(context).size.width;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dobrodošli v EMP-Calendar",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
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
                        TextField(
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
                        ),
                        if (filteredUsersList.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            height: 150,
                            child: ListView.builder(
                              itemCount: filteredUsersList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(filteredUsersList[index]),
                                  onTap: () {
                                    emailController.text = filteredUsersList[index];
                                    ref.read(filteredUsersProvider.notifier).state = [];
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
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
                        ),
                        Row(
                          children: [
                            const Text("Zapomni se me"),
                            Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                ref.read(checkProvider.notifier).state = value ?? false;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        MaterialButton(
                          onPressed: () async {
                            bool saveLoginData = ref.read(checkProvider.notifier).state == true;
                            await saveUser(User(
                              email: saveLoginData? emailController.text : "",
                              password: saveLoginData? passwordController.text : "",
                            ));
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          },
                          color: const Color(0xff3a57e8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.all(16),
                          minWidth: contextSizeWidth,
                          child: const Text(
                            "Vpis",
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
                                    MaterialPageRoute(builder: (context) => const SubscribePage()),
                                  );
                                },
                                child: const Text(
                                  "Registracija?",
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
          ],
        ),
      ),
    );
  }
}
