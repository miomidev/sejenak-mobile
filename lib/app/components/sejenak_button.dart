import 'package:flutter/material.dart';

import '../../root/sejenak_color.dart';

class SejenakButton extends StatelessWidget {
  final String text;
  final VoidCallback action;

  const SejenakButton({
    super.key,
    required this.text,
    required this.action,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: action,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(SejenakColor.secondary),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        )),
        elevation: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.hovered)) {
            return 10.0;
          }
          return 4.0;
        }),
        shadowColor: WidgetStateProperty.all(Colors.black),
      ),
      child: Text(
        text,
        style: const TextStyle(color: SejenakColor.light),
      ),
    );
  }
}
