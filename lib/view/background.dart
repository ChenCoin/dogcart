import 'dart:math';

import 'package:flutter/material.dart';

class BackgroundBoard extends StatefulWidget {
  final Size size;

  const BackgroundBoard({super.key, required this.size});

  @override
  State<StatefulWidget> createState() => _BackgroundState();
}

class _BackgroundState extends State<BackgroundBoard> {
  List<(double, double, double)> starList = <(double, double, double)>[];

  @override
  void initState() {
    super.initState();
    final random = Random();
    int starCount = 10 + random.nextInt(6);
    for (int i = 0; i < starCount; i++) {
      double r = (2 + random.nextInt(4)).toDouble();
      starList.add((random.nextDouble(), random.nextDouble(), r));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _MyPainter(starList),
    );
  }
}

class _MyPainter extends CustomPainter {
  final List<(double, double, double)> starList;

  final gradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF2c2e78), Color(0xFF3c2d58)],
  );

  final bgrPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  final starPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF06d7f6);

  final moonGradient = const RadialGradient(
    colors: [Color(0xFF432e5c), Color(0xFF391e3f)],
  );

  final moonPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  _MyPainter(this.starList);

  @override
  void paint(Canvas canvas, Size size) {
    bgrPaint.shader = gradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgrPaint);

    final moonSize = min(size.width, size.height);
    final r = moonSize / 2;
    final offset = Offset(-10, size.height + 40);
    final rect = Rect.fromCircle(center: offset, radius: r);
    moonPaint.shader = moonGradient.createShader(rect);
    canvas.drawCircle(offset, r, moonPaint);

    double w = size.width;
    double h = size.height;
    for (final star in starList) {
      canvas.drawCircle(Offset(star.$1 * w, star.$2 * h), star.$3, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
