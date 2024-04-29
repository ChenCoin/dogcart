import 'package:flutter/material.dart';

import '../data/grid_data.dart';
import '../data/grid_point.dart';
import 'shape_draw.dart';

class EffectBoard extends StatefulWidget {
  final Size size;

  final GridData data;

  final void Function() callback;

  const EffectBoard(
      {super.key,
      required this.size,
      required this.data,
      required this.callback});

  @override
  State<StatefulWidget> createState() => _EffectBoardState();
}

class _EffectBoardState extends State<EffectBoard>
    with TickerProviderStateMixin {
  var allController = <AnimationController>[];

  @override
  void initState() {
    super.initState();
    debugPrint('-------------initState');
    widget.data.onViewInit(createBreakStar, createMovingStar);
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
        controller.dispose();
        widget.data.removeBreakStarList(breakStars);
      }
    });
    widget.data.addBreakStarList(breakStars);
    allController.add(controller);
    controller.forward();
  }

  void createMovingStar(List<StarGrid> list) {
    Duration duration = const Duration(milliseconds: 800);
    var controller = AnimationController(duration: duration, vsync: this);
    // animation用于获取数值
    var curve = CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);
    Animation<double> anim = Tween(begin: 0.0, end: 100.0).animate(curve)
      ..addListener(() => setState(() {}));
    for (var item in list) {
      item.willMove(anim);
    }
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        allController.remove(controller);
        controller.dispose();
        for (var item in list) {
          if (item.anim == anim) {
            item.endMove();
          }
        }
        widget.callback();
      }
    });
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
    drawBreakStar(canvas, gap, grid);
    drawMovingStar(canvas, gap, grid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawBreakStar(Canvas canvas, int gap, double grid) {
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

  void drawMovingStar(Canvas canvas, int gap, double grid) {
    // 绘制格子
    var gridPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    var starPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    int gap = GridData.gap;
    for (int dy = 0; dy < GridData.row; dy++) {
      for (int dx = 0; dx < GridData.col; dx++) {
        var gridPoint = data.grids[dy][dx];
        if (!gridPoint.isMoving()) {
          continue;
        }
        double anim = gridPoint.anim?.value ?? 0;
        double posY = gridPoint.position.y;
        double i = posY + (dy - posY) * anim / 100;
        double posX = gridPoint.position.x;
        double j = posX + (dx - posX) * anim / 100;

        (int, int) color = gridPoint.color;
        gridPaint.color = Color(color.$2);

        // 画圆角方块
        var left = grid * j + gap * (j + 1);
        var top = grid * i + gap * (i + 1);
        Path roundRect = drawSmoothRoundRect(left, top, grid, grid, 12);
        canvas.drawPath(roundRect, gridPaint);

        // 画五角星
        Path path = drawStar(
            grid / 2 - 2, grid / 4, left + grid / 2, top + grid / 2, 0);
        canvas.drawShadow(path, const Color(0xFF808080), 3, false);
        starPaint.color = Color(color.$1);
        canvas.drawPath(path, starPaint);
      }
    }
  }
}
