import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_button.dart';
import 'package:selena/app/components/sejenak_loading.dart';
import 'package:selena/services/auth/auth.dart';

import '../../services/controller.dart';
import '../../style/sejenak_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<RegisterScreen> {
  final AuthFormController sejenak = AuthFormController();
  final Dio dio = Dio();
  late SejenakApiAuthService auth;
  @override
  void initState() {
    super.initState();
    auth = SejenakApiAuthService(sejenak);
  }

  bool isLoading = false;

  Future<void> handleRegister() async {
    setState(() => isLoading = true);

    await auth.register(context);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: SejenakLoading())
          : Center(
              child: Container(
                width: 251,
                decoration: SejenakContainer.primaryBox,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "REGISTER",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          maxLength: 50,
                          controller: sejenak.name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            labelStyle: TextStyle(
                                color: Colors.blueGrey, fontFamily: 'Lexend'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          maxLength: 50,
                          controller: sejenak.username,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(
                                color: Colors.blueGrey, fontFamily: 'Lexend'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          maxLength: 50,
                          controller: sejenak.email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                                color: Colors.blueGrey, fontFamily: 'Lexend'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          controller: sejenak.password,
                          maxLength: 20,
                          decoration: const InputDecoration(
                            labelText: 'password',
                            labelStyle: TextStyle(
                                color: Colors.blueGrey, fontFamily: 'Lexend'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          controller: sejenak.passwordVerification,
                          maxLength: 20,
                          decoration: const InputDecoration(
                            labelText: 'confirm password',
                            labelStyle: TextStyle(
                                color: Colors.blueGrey, fontFamily: 'Lexend'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SejenakButton(text: "register", action: handleRegister)
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
