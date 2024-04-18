import 'package:flutter/material.dart';

import '../data/grid_data.dart';
import 'shape_draw.dart';

class StarBoard extends StatefulWidget {
  final Size size;

  final GridData data;

  final void Function(bool) callback;

  const StarBoard(
      {super.key,
      required this.size,
      required this.data,
      required this.callback});

  @override
  State<StatefulWidget> createState() => _StarBoardState();
}

class _StarBoardState extends State<StarBoard> {
  @override
  Widget build(BuildContext context) {
    var size = widget.size;
    return GestureDetector(
      onTapUp: (e) {
        onTap(e.localPosition.dx, e.localPosition.dy);
      },
      child: CustomPaint(
        size: size,
        painter: _MyPainter(width: size.width, data: widget.data),
      ),
    );
  }

  void onTap(double dx, double dy) {
    double grid = widget.size.width / GridData.col;
    int score = widget.data.onTap((dx / grid).floor(), (dy / grid).floor());
    if (score >= 2) {
      widget.callback(widget.data.checkIfGameFinish());
    }
  }
}

class _MyPainter extends CustomPainter {
  final double width;

  final GridData data;

  _MyPainter({required this.width, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    double grid = data.obtainGrid(width);
    drawBackground(canvas, rect, grid);

    // 绘制格子
    var gridPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    var starPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    int gap = GridData.gap;
    for (int i = 0; i < GridData.row; i++) {
      for (int j = 0; j < GridData.col; j++) {
        int colorValue = data.grids[i][j];
        if (colorValue == 0) {
          continue;
        }
        (int, int) color = colorMap(colorValue);
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawBackground(Canvas canvas, Rect rect, double grid) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFEAEAE8)
      ..strokeWidth = 1.0;

    // 画横线
    int floor = (GridData.gap / 2).floor();
    for (int i = 0; i <= GridData.row; i++) {
      double dy = rect.top + (grid + GridData.gap) * i + floor;
      canvas.drawLine(Offset(rect.left + floor, dy),
          Offset(rect.right - floor * 2 + 2, dy), paint);
    }

    // 画竖线
    for (int i = 0; i <= GridData.col; i++) {
      double dx = rect.left + (grid + GridData.gap) * i + floor;
      canvas.drawLine(Offset(dx, rect.top + floor),
          Offset(dx, rect.bottom - floor * 2 + 2), paint);
    }
  }

  // 颜色匹配
  (int, int) colorMap(int number) {
    switch (number) {
      case 1:
        return (0xFFEC7062, 0xFFE74C3C); // red
      case 2:
        return (0xFF5CADE2, 0xFF5599C7); // blue
      case 3:
        return (0xFFF4CF40, 0xFFF5B041); // yellow
      case 4:
        return (0xFFAF7AC4, 0xFFA569BD); // purple
      case 5:
        return (0xFF57D68C, 0xFF53BE80); // green
      default:
        return (0, 0);
    }
  }
}
