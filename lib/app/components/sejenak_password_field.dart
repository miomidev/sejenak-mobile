import 'package:flutter/material.dart';

import '../../root/sejenak_color.dart';

class SejenakPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String text;

  const SejenakPasswordField({
    super.key,
    required this.controller,
    this.text = '',
  });

  @override
  _SejenakPasswordFieldState createState() => _SejenakPasswordFieldState();
}

class _SejenakPasswordFieldState extends State<SejenakPasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured, // Toggle password visibility
      decoration: InputDecoration(
        labelText: widget.text,
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
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: SejenakColor.stroke, // Ganti warna jika tidak muncul
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured; // Toggle visibility
            });
          },
        ),
      ),
    );
  }
}
