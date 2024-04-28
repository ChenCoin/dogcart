import 'package:flutter/material.dart';

import '../data/grid_data.dart';
import '../data/grid_point.dart';
import 'shape_draw.dart';

class EffectBoard extends StatefulWidget {
  final Size size;

  final GridData data;

  const EffectBoard({super.key, required this.size, required this.data});

  @override
  State<StatefulWidget> createState() => _EffectBoardState();
}

class _EffectBoardState extends State<EffectBoard>
    with TickerProviderStateMixin {
  var allController = <AnimationController>[];

  @override
  void initState() {
    super.initState();
    widget.data.onViewInit(createBreakStar);
  }

  @override
  Widget build(BuildContext context) {
    var size = widget.size;
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: _MyPainter(width: size.width, data: widget.data),
      ),
    );
  }

  @override
  void dispose() {
    for (var element in allController) {
      element.dispose();
    }
    super.dispose();
    allController.clear();
    widget.data.onDispose();
  }

  void createBreakStar(List<ColorPoint> list) {
    Duration duration = const Duration(milliseconds: 800);
    var controller = AnimationController(duration: duration, vsync: this);
    // animation用于获取数值
    var curve = CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);
    Animation<double> anim = Tween(begin: 100.0, end: 0.0).animate(curve)
      ..addListener(() => setState(() {}));
    var breakStars = BreakStarList(list, anim);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        allController.remove(controller);
        widget.data.removeBreakStarList(breakStars);
      }
    });
    widget.data.addBreakStarList(breakStars);
    allController.add(controller);
    controller.forward();
  }
}

class _MyPainter extends CustomPainter {
  final double width;

  final GridData data;

  _MyPainter({required this.width, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    int gap = GridData.gap;
    double grid = data.obtainGrid(width);
    List<BreakStarList> breakStars = data.breakStarList;
    var starPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    for (var item in breakStars) {
      if (item.anim.status != AnimationStatus.forward) {
        continue;
      }
      var animValue = item.anim.value;
      List<ColorPoint> list = item.list;
      for (var colorPoint in list) {
        int i = colorPoint.y;
        int j = colorPoint.x;
        // 画圆角方块
        var left = grid * j + gap * (j + 1);
        var top = grid * i + gap * (i + 1);
        double R = (grid / 2 - 2) * animValue / 100;
        double r = (grid / 4) * animValue / 100;
        // 画五角星
        Path path = drawStar(R, r, left + grid / 2, top + grid / 2, 0);
        canvas.drawShadow(path, const Color(0xFF808080), 3, false);
        starPaint.color = Color(colorPoint.color.$1);
        canvas.drawPath(path, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
