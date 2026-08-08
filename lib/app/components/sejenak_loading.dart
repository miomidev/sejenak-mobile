import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakLoading extends StatelessWidget {
  const SejenakLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            width: 100,
            height: 100,
            child: SvgPicture.asset(
              'assets/svg/sejenak.svg',
              colorFilter:
                  ColorFilter.mode(SejenakColor.secondary, BlendMode.srcIn),
            )),
        SejenakText(
          text: "SEJENAK",
          type: SejenakTextType.h5,
          // color: SejenakColor.light,
          maxLines: 2,
        ),
        SejenakText(
          text: "a safe space for everybody",
          type: SejenakTextType.regular,
          // color: SejenakColor.light,
          maxLines: 2,
        ),
      ],
    );
  }
}
