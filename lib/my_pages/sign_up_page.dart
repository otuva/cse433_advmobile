import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cse433_advmobile/auth.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String errorMessage = "";
  String password = "";
  String passwordconfirm = "";
  String email = "";
  String name = "";

  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      await Auth()
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message!;
    }
  }

  bool passwordVisible = true;
  bool passwordVisible1 = true;
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade700, width: 1.0)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    label: const Text("Enter your Name",
                        style: TextStyle(color: Colors.white)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  }),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade700, width: 1.0)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    label: const Text("Enter your email",
                        style: TextStyle(color: Colors.white)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your email";
                    }
                    return null;
                  }),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  onChanged: (value) => password = value,
                  obscureText: passwordVisible1,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible1
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() => passwordVisible1 = !passwordVisible1);
                      },
                      iconSize: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade700, width: 1.0)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    label: const Text("Enter your password",
                        style: TextStyle(color: Colors.white)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  }),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() => passwordVisible = !passwordVisible);
                      },
                      iconSize: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade700, width: 1.0)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    label: const Text("Confirm your password",
                        style: TextStyle(color: Colors.white)),
                  ),
                  obscureText: passwordVisible,
                  onChanged: (value) {
                    setState(() {
                      passwordconfirm = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  }),
              const SizedBox(
                height: 150,
              ),
              SizedBox(
                height: 40,
                width: 420,
                child: ElevatedButton(
                    onPressed: () {
                      if (!_formkey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Passwords do not match')),
                        );
                      } else {
                        if (password == passwordconfirm &&
                            password.isNotEmpty &&
                            email.isNotEmpty &&
                            name.isNotEmpty) {
                          createUserWithEmailAndPassword(email, password)
                              .whenComplete(() {
                            Navigator.pushAndRemoveUntil(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          });
                        }
                      }
                    },
                    child: const Text("Sign Up")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
