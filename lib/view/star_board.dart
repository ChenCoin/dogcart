import 'package:flutter/material.dart';

import '../data/grid_data.dart';
import 'shape_draw.dart';

class StarBoard extends StatefulWidget {
  final Size size;

  final GridData data;

  const StarBoard({super.key, required this.size, required this.data});

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
      setState(() {});
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
    // 背景填充灰色
    var thePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(rect, thePaint);

    // 绘制格子
    var gridPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    var starPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Colors.black12;

    double grid = data.obtainGrid(width);
    int gap = GridData.gap;
    for (int i = 0; i < GridData.row; i++) {
      for (int j = 0; j < GridData.col; j++) {
        int color = data.grids[i][j];
        if (color == 0) {
          continue;
        }
        gridPaint.color = Color(color);

        // 画圆角方块
        var left = grid * j + gap * (j + 1);
        var top = grid * i + gap * (i + 1);
        Path roundRect = drawSmoothRoundRect(left, top, grid, grid, 12);
        canvas.drawPath(roundRect, gridPaint);

        // 画五角星
        Path path = drawStar(
            grid / 2 - 2, grid / 4 - 2, left + grid / 2, top + grid / 2, 0);
        canvas.drawPath(path, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
