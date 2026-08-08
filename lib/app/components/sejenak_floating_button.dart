import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakFloatingButton extends StatelessWidget {
  final Function()? onPressed;
  const SejenakFloatingButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      constraints: const BoxConstraints.tightFor(
        width: 56,
        height: 56,
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: SejenakColor.primary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.0,
            color: Colors.grey[900]!,
          ),
          boxShadow: const [
            BoxShadow(
              color: SejenakColor.black,
              spreadRadius: 0.4,
              blurRadius: 0,
              offset: Offset(0.3, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset('assets/svg/pen.svg',
            width: 22, height: 22, color: SejenakColor.stroke),
      ),
    );
  }
}
