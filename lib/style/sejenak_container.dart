import 'package:flutter/material.dart';

import '../root/sejenak_color.dart';

class SejenakContainer {
  static final BoxDecoration primaryBox = BoxDecoration(
      color: SejenakColor.primary,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: SejenakColor.black,
          spreadRadius: 0.2,
          blurRadius: 0,
          offset: Offset(
            0.1,
            4,
          ),
        ),
      ]);
}
