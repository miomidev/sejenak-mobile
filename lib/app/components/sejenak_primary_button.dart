import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../root/sejenak_color.dart';

class SejenakPrimaryButton extends StatefulWidget {
  final String text;
  final String fontStyle;
  final String icon;
  final Color color;
  final double fontSize;
  final double? width;
  final double paddingY;
  final double paddingX;
  final double? height;
  final Future<void> Function() action;

  const SejenakPrimaryButton({
    super.key,
    required this.text,
    required this.action,
    this.icon = '',
    this.width,
    this.height,
    this.paddingX = 16,
    this.paddingY = 12,
    this.color = SejenakColor.primary,
    this.fontStyle = 'Lexend',
    this.fontSize = 14.24,
  });

  @override
  _SejenakPrimaryButtonState createState() => _SejenakPrimaryButtonState();
}

class _SejenakPrimaryButtonState extends State<SejenakPrimaryButton> {
  bool click = false;
  double opacity = 1.0;
  double offsetY = 0.0;

  Future<void> _onclick() async {
    setState(() {
      click = true;
      opacity = 0.6;
      offsetY = 4.0;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      click = false;
      opacity = 1.0;
      offsetY = 0.0;
    });
    await widget.action();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onclick,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: opacity,
        child: AnimatedContainer(
          width: widget.width,
          height: widget.height,
          duration: const Duration(milliseconds: 200),
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: widget.paddingX, vertical: widget.paddingY),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.0,
                  color: Colors.grey[900]!,
                ),
                color: widget.color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: !click
                    ? [
                        const BoxShadow(
                          color: SejenakColor.black,
                          spreadRadius: 0.2,
                          blurRadius: 0,
                          offset: Offset(0.1, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.icon.isNotEmpty)
                    SvgPicture.asset(
                      widget.icon,
                      width: 24.21,
                      height: 24.71,
                    ),
                  if (widget.icon.isNotEmpty && widget.text.isNotEmpty)
                    const SizedBox(width: 12.29),
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: widget.fontStyle,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.normal,
                      color: SejenakColor.stroke,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
