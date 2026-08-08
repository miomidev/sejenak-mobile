import 'package:flutter/material.dart';

import '../../root/sejenak_color.dart';

class SejenakTextField extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  const SejenakTextField({super.key, required this.controller, this.text = ''});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 50,
      controller: controller,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: TextStyle(
          color: SejenakColor.secondary,
          fontSize: 14.24,
          fontWeight: FontWeight.normal,
          fontFamily: 'Lexend',
          wordSpacing: 0.4,
        ),
        filled: true,
        fillColor: SejenakColor.white,
        counterText: '',
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: SejenakColor.stroke, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: SejenakColor.primary, width: 2),
        ),
      ),
    );
  }
}
