import 'package:flutter/material.dart';

import '../../root/sejenak_color.dart';

class SejenakText extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextStyle? style;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final Color color;
  final TextOverflow overflow;
  final SejenakTextType type;

  const SejenakText(
      {super.key,
      required this.text,
      this.style,
      this.overflow = TextOverflow.ellipsis,
      this.maxLines,
      this.color = SejenakColor.stroke,
      this.textAlign = TextAlign.center,
      this.type = SejenakTextType.regular,
      this.fontWeight = FontWeight.normal});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style ?? _getTextStyle(fontWeight),
      maxLines: maxLines,
    );
  }

  TextStyle _getTextStyle(FontWeight fontWeight) {
    switch (type) {
      case SejenakTextType.h1:
        return TextStyle(
            fontSize: 67.36,
            fontWeight: FontWeight.bold,
            fontFamily: 'Exo2',
            wordSpacing: 0.1,
            color: color);
      case SejenakTextType.h2:
        return TextStyle(
            fontSize: 50.6,
            fontWeight: FontWeight.bold,
            fontFamily: 'Exo2',
            color: color,
            wordSpacing: 0.1);
      case SejenakTextType.h3:
        return TextStyle(
            fontSize: 37.9,
            fontWeight: FontWeight.bold,
            fontFamily: 'Exo2',
            color: color,
            wordSpacing: 0.2);
      case SejenakTextType.h4:
        return TextStyle(
            fontSize: 28.48,
            fontWeight: FontWeight.bold,
            fontFamily: 'Exo2',
            color: color,
            wordSpacing: 0.4);
      case SejenakTextType.h5:
        return TextStyle(
            fontSize: 21.28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Exo2',
            color: color,
            wordSpacing: 0.4);
      case SejenakTextType.regular:
        return TextStyle(
            fontSize: 14.24,
            fontWeight: fontWeight,
            fontFamily: 'Lexend',
            color: color,
            wordSpacing: 0.4);
      case SejenakTextType.small:
        return TextStyle(
            fontSize: 12,
            fontWeight: fontWeight,
            fontFamily: 'Lexend',
            color: color,
            wordSpacing: 0.4);
    }
  }
}

enum SejenakTextType { h1, h2, h3, h4, h5, regular, small }
