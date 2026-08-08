import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class SvgPathClipper extends CustomClipper<Path> {
  final String svgPathData;

  SvgPathClipper(this.svgPathData);

  @override
  Path getClip(Size size) {
    final Path path = parseSvgPathData(svgPathData);
    final Matrix4 matrix4 = Matrix4.identity();

    // Skalakan path agar sesuai ukuran container
    matrix4.scale(size.width / 100, size.height / 100);
    return path.transform(matrix4.storage);
  }

  @override
  bool shouldReclip(SvgPathClipper oldClipper) {
    return oldClipper.svgPathData != svgPathData;
  }
}
