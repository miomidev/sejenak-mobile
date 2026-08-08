import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakCircular extends StatefulWidget {
  const SejenakCircular({super.key});

  @override
  State<SejenakCircular> createState() => _SejenakWaveProgressState();
}

class _SejenakWaveProgressState extends State<SejenakCircular>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _riseController;

  @override
  void initState() {
    super.initState();

    // Controller buat animasi ombak
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Controller buat animasi naiknya baseline
    _riseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.3,
      upperBound: 0.9,
    )
      ..value = 0.3
      ..forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _riseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: 150,
        height: 100,
        color: const Color.fromARGB(48, 228, 219, 162),
      ),
      Positioned(
        bottom: 1,
        left: 1,
        child: SizedBox(
          width: 155,
          height: 50,
          child: AnimatedBuilder(
            animation: Listenable.merge([_waveController, _riseController]),
            builder: (context, _) {
              return CustomPaint(
                painter: _WavePainter(
                  waveProgress: _waveController.value,
                  riseProgress: _riseController.value,
                ),
              );
            },
          ),
        ),
      ),
      SvgPicture.asset('assets/svg/frame_loading.svg',
          width: 150,
          height: 150,
          color: SejenakColor.white, // warna overlay
          colorBlendMode: BlendMode.srcIn),
    ]);
  }
}

class _WavePainter extends CustomPainter {
  final double waveProgress;
  final double riseProgress;

  _WavePainter({
    required this.waveProgress,
    required this.riseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double waveHeight = 6;
    final double frequency = 3.5;
    final double riseAmount = riseProgress * 115;

    final double baseHeight = (size.height * 0.9) - riseAmount;
    final double baseHeight2 = (size.height * 0.95) - riseAmount;

    // === Gelombang Kanan ===
    final pathRight = Path()..moveTo(0, baseHeight);
    for (double x = 0; x <= size.width; x++) {
      double y =
          sin((x / size.width * 2 * pi * frequency) + waveProgress * 2 * pi) *
              waveHeight;
      pathRight.lineTo(x, baseHeight + y);
    }
    pathRight.lineTo(size.width, size.height);
    pathRight.lineTo(0, size.height);
    pathRight.close();

    canvas.drawPath(
      pathRight,
      Paint()
        ..color = SejenakColor.primary.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );

    // === Gelombang Kiri ===
    final pathLeft = Path()..moveTo(0, baseHeight2);
    for (double x = 0; x <= size.width; x++) {
      double y =
          sin((x / size.width * 2 * pi * frequency) - waveProgress * 2 * pi) *
              waveHeight;
      pathLeft.lineTo(x, baseHeight2 + y);
    }
    pathLeft.lineTo(size.width, size.height);
    pathLeft.lineTo(0, size.height);
    pathLeft.close();

    canvas.drawPath(
      pathLeft,
      Paint()
        ..color = SejenakColor.secondary.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
