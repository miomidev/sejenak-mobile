import 'package:flutter/material.dart';

class AuthFormController {
  final TextEditingController name = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController passwordVerification = TextEditingController();
  final TextEditingController code = TextEditingController();
  void dispose() {
    name.dispose();
    password.dispose();
    email.dispose();
    username.dispose();
    passwordVerification.dispose();
    code.dispose();
  }
}
