import 'package:flutter/material.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakContainer extends StatelessWidget {
  final Widget? child;
  const SejenakContainer({super.key, this.child});
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
              color: Colors.grey[900]!,
            ),
            color: SejenakColor.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              const BoxShadow(
                color: SejenakColor.black,
                spreadRadius: 0.2,
                blurRadius: 0,
                offset: Offset(0.1, 4),
              ),
            ]),
        child: child != null
            ? Padding(padding: const EdgeInsets.only(left: 10), child: child)
            : null);
  }
}
