import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'shape_draw.dart';

class MeteorBoard extends StatefulWidget {
  final Size size;

  const MeteorBoard({super.key, required this.size});

  @override
  State<StatefulWidget> createState() => _MeteorState();
}

class _MeteorState extends State<MeteorBoard> with TickerProviderStateMixin {
  // 每5秒执行一次流星尝试
  static const int _meteorDuration = 5;

  // 1/3的概率显示流星
  static const int _probability = 3;

  // 流星动画的时长为3秒
  static const int _animationDuration = 3;

  late Timer _timer;

  late AnimationController controller;

  late Animation<double> anim;

  AnimInfo animInfo = AnimInfo(false, 0, 0);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: _meteorDuration), onTick);
    var duration = const Duration(seconds: _animationDuration);
    controller = AnimationController(duration: duration, vsync: this);
    // animation用于获取数值
    var curve = CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);
    anim = Tween(begin: 0.0, end: 100.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animInfo.active = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _MyPainter(anim, animInfo),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    _timer.cancel();
  }

  void onTick(Timer timer) {
    var random = Random();
    var value = random.nextInt(_probability);
    if (value != 0) {
      animInfo.active = false;
      return;
    }
    animInfo.active = true;
    animInfo.setValue(createAnimPair(random));
    controller.reset();
    controller.forward();
  }

  (double, double) createAnimPair(Random random) {
    double startDx = random.nextDouble();
    double endDx = random.nextDouble();

    var width = widget.size.width;
    double startPointX = (startDx * 2 - 0.5) * width;
    double endPointX = width * (endDx + 0.5);
    if (startDx > 0.5) {
      endPointX = width - endPointX;
    }
    return (startPointX, endPointX);
  }
}

class _MyPainter extends CustomPainter {
  final starPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = const Color(0xFFF4CF40);

  final Path _path = Path();

  final double grid = 24;

  Animation<double> anim;

  AnimInfo animInfo;

  _MyPainter(this.anim, this.animInfo);

  @override
  void paint(Canvas canvas, Size size) {
    if (!animInfo.active) {
      return;
    }
    var startX = animInfo.top;
    double dx = (animInfo.bottom - startX) * anim.value / 100 + startX;
    double dy = (size.height + grid * 2) * anim.value / 100 - grid;
    var rot = 360 * anim.value / 32;
    drawStar(_path, grid / 2 - 2, grid / 4, dx, dy, rot);
    canvas.drawPath(_path, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => animInfo.active;
}

class AnimInfo {
  bool active;
  double top;
  double bottom;

  AnimInfo(this.active, this.top, this.bottom);

  void setValue((double, double) value) {
    top = value.$1;
    bottom = value.$2;
  }
}
