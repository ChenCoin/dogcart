import 'package:flutter/material.dart';

import '../data/grid_data.dart';
import '../ux.dart';
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
        painter: _MyPainter(data: widget.data),
      ),
    );
  }

  void onTap(double dx, double dy) {
    // the grid here is not same as GridData.grid
    double grid = widget.size.width / UX.col;
    bool isStarBroke =
        widget.data.onTap((dx / grid).floor(), (dy / grid).floor());
    if (isStarBroke) {
      widget.callback(widget.data.checkIfGameFinish());
    }
  }
}

class _MyPainter extends CustomPainter {
  final GridData data;

  final path = Path();

  final gridPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  final starPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  final bgrPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..color = const Color(0xFFEAEAE8)
    ..strokeWidth = 1.0;

  _MyPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    double grid = data.grid;
    drawBackground(canvas, rect, grid);

    // draw grids
    for (int i = 0; i < UX.row; i++) {
      for (int j = 0; j < UX.col; j++) {
        var gridPoint = data.grids[i][j];
        if (gridPoint.isEmpty() || gridPoint.isMoving()) {
          continue;
        }
        (int, int) color = gridPoint.color;
        gridPaint.color = Color(color.$2);

        // draw round grid
        var left = gridPoint.left;
        var top = gridPoint.top;
        drawSmoothRoundRect(path, left, top, grid, grid, 12);
        canvas.drawPath(path, gridPaint);

        // draw star
        left = left + grid / 2;
        top = top + grid / 2;
        drawStar(path, grid / 2 - 2, grid / 4, left, top, 0);
        canvas.drawShadow(path, const Color(0xFF808080), 3, false);
        starPaint.color = Color(color.$1);
        canvas.drawPath(path, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawBackground(Canvas canvas, Rect rect, double grid) {
    // draw row line
    int floor = (GridData.gap / 2).floor();
    for (int i = 0; i <= UX.row; i++) {
      double dy = rect.top + (grid + GridData.gap) * i + floor;
      canvas.drawLine(Offset(rect.left + floor, dy),
          Offset(rect.right - floor * 2 + 2, dy), bgrPaint);
    }

    // draw col line
    for (int i = 0; i <= UX.col; i++) {
      double dx = rect.left + (grid + GridData.gap) * i + floor;
      canvas.drawLine(Offset(dx, rect.top + floor),
          Offset(dx, rect.bottom - floor * 2 + 2), bgrPaint);
    }
  }
}
