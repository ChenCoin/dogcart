import 'package:flutter/material.dart';

import '../data/grid_data.dart';
import '../ux.dart';
import 'shape_draw.dart';

class SceneBoard extends StatefulWidget {
  final Size size;

  final GridData data;

  const SceneBoard({super.key, required this.size, required this.data});

  @override
  State<StatefulWidget> createState() => _SceneBoardState();
}

class _SceneBoardState extends State<SceneBoard> with TickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> anim;

  @override
  void initState() {
    super.initState();
    // 减少100毫秒，规避动画缺失的问题
    var duration = const Duration(milliseconds: UX.enterSceneDuration - 100);
    controller = AnimationController(duration: duration, vsync: this);
    var curve = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    anim = Tween(begin: 0.0, end: 100.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _MyPainter(data: widget.data, anim: anim),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _MyPainter extends CustomPainter {
  final GridData data;

  final Animation<double> anim;

  final path = Path();

  final starPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  final gridPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  _MyPainter({required this.data, required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('anim ${anim.value}');
    drawMovingStar(canvas, data, path, gridPaint, starPaint, (p) => anim.value);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
