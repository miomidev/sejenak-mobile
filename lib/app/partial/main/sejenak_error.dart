import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selena/app/components/sejenak_text.dart';

class SejenakError extends StatelessWidget {
  final String? message;
  SejenakError({super.key, this.message}) {
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/icon.svg',
            width: 100,
            height: 100,
          ),
          SejenakText(
            text: 'WOPS...!',
            type: SejenakTextType.h5,
          ),
          SejenakText(
            text: this.message ?? '',
            type: SejenakTextType.regular,
          ),
        ],
      ),
    );
  }
}
