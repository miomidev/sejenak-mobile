import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';

class SejenakDetailPost extends StatelessWidget {
  const SejenakDetailPost({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        SejenakText(
          text: "John Sekejap",
          type: SejenakTextType.h4,
        )
      ],
    ));
  }
}
