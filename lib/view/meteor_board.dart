import 'package:flutter/material.dart';

class MeteorBoard extends StatefulWidget {
  final Size size;

  const MeteorBoard({super.key, required this.size});

  @override
  State<StatefulWidget> createState() => _MeteorState();
}

class _MeteorState extends State<MeteorBoard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _MyPainter(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
