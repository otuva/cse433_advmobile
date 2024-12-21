import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cse433_advmobile/auth.dart';
import 'package:cse433_advmobile/my_pages/dashboard.dart';

// ignore: must_be_immutable
class PasswordPage extends StatefulWidget {
  String email;
  PasswordPage({super.key, required this.email});

  // Widget title() {
  //   return const Text(
  //     'Log in to Twitter.',
  //     style: TextStyle(
  //         fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  //   );
  // }

  // Widget userId() {
  //   return Text(user?.email ?? "user email",
  //       style: const TextStyle(
  //           fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white));
  // }

  // Widget signOutButton() {
  //   return ElevatedButton(onPressed: _signOut, child: Text("Sign out"));
  // }

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  String password = "";
  String errorMessage = "";
  bool isLogin = false;
  final _formkey = GlobalKey<FormState>();
  bool passwordVisible = true;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await Auth().signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        isLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLogin = false;
      });
      errorMessage = e.message!;
    }
  }

  final User? user = Auth().currentUser;

  // Future<void> _signOut() async {
  //   await Auth().signOut();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(
        centerTitle: true,
        title: const Image(
            image: AssetImage('assets/images/library.png'), height: 30),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              const Text('Enter your password',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  width: 300,
                  child: TextFormField(
                      onChanged: (value) => password = value,
                      obscureText: passwordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade700, width: 1.0)),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        label: const Text("Password",
                            style: TextStyle(color: Colors.white)),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      }),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (!_formkey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('User not found or wrong password')),
                        );
                      } else {
                        signInWithEmailAndPassword(widget.email, password)
                            .whenComplete(() {
                          if (isLogin) {
                            // ignore: use_build_context_synchronously
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const MyHomePage();
                            }));
                          } else {}
                        });
                      }
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
