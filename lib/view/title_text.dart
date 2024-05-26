import 'dart:math';

import 'package:flutter/material.dart';

import '../content.dart';

class TitleText extends StatelessWidget {
  final Size size;

  const TitleText({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _MyPainter(),
    );
  }
}

class _MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
