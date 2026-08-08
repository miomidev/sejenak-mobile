import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:selena/app/components/sejenak_loading.dart';
import 'package:selena/app/components/sejenak_password_field.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/components/sejenak_text_field.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/auth/auth.dart';

import '../../services/controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final AuthFormController sejenak = AuthFormController();
  late SejenakApiAuthService auth;
  @override
  void initState() {
    super.initState();
    auth = SejenakApiAuthService(sejenak);
  }

  String get authUrl => 'http://192.168.1.21:8000/api';
  bool isLoading = false;

  Future<void> handleRegister() async {
    setState(() => isLoading = true);
    print(sejenak.name.text);
    print(sejenak.password.text);
    print(sejenak.email.text);
    await auth.register(context);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Icon(Icons.close, color: SejenakColor.primary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: isLoading
          ? const Center(child: SejenakLoading())
          : Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 64, right: 64),
                child: Column(
                  children: [
                    SizedBox(
                      height: 64,
                    ),
                    SvgPicture.asset(
                      'assets/svg/logo_mini.svg',
                      width: 40,
                      height: 37,
                      colorFilter: ColorFilter.mode(
                        SejenakColor.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SejenakText(
                      text: "Sejenak",
                      type: SejenakTextType.h3,
                    ),
                    SizedBox(
                      height: 103,
                    ),
                    SejenakText(
                      text: "Daftar dengan Email",
                      type: SejenakTextType.h5,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SejenakTextField(
                      text: "Name",
                      controller: sejenak.name,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SejenakTextField(
                      text: "Username",
                      controller: sejenak.username,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SejenakTextField(
                      text: "Email",
                      controller: sejenak.email,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SejenakPasswordField(
                      text: "Password",
                      controller: sejenak.password,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SejenakPasswordField(
                      text: "Confirm Password",
                      controller: sejenak.passwordVerification,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SejenakPrimaryButton(
                      text: "Register",
                      action: handleRegister,
                      color: SejenakColor.secondary,
                    ),
                    SizedBox(
                      height: 21,
                    ),
                    SejenakText(
                      text:
                          "Dengan membuat akun, anda setuju dengan Kebijakan Penggunaan kamu dan memahami bahwa Kebijakan Privasi kami ",
                      type: SejenakTextType.small,
                      color: SejenakColor.secondary,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
