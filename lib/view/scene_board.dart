import 'package:flutter/material.dart';

import '../data/grid_data.dart';

class SceneBoard extends StatefulWidget {
  final Size size;

  final GridData data;

  const SceneBoard(
      {super.key,
      required this.size,
      required this.data});

  @override
  State<StatefulWidget> createState() => _SceneBoardState();
}

class _SceneBoardState extends State<SceneBoard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _MyPainter(data: widget.data),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _MyPainter extends CustomPainter {
  final GridData data;

  _MyPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
