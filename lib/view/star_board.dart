import 'package:flutter/material.dart';

import '../data/grid_data.dart';

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
    widget.data.printGrids();
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
    var thePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.grey;
    canvas.drawRect(rect, thePaint);

    int p = 2;
    var gridPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    double grid = size.width / GridData.col;
    for (int i = 0; i < GridData.row; i++) {
      for (int j = 0; j < GridData.col; j++) {
        Color color = Color(data.grids[i][j]);

        // 画小白块
        var left = grid * j + p;
        var top = grid * i + p;
        var right = left + grid - p * 2;
        var bottom = top + grid - p * 2;
        var rect = Rect.fromLTRB(left, top, right, bottom);
        gridPaint.color = color;
        RRect whiteGrid =
            RRect.fromRectAndRadius(rect, const Radius.circular(2));
        canvas.drawRRect(whiteGrid, gridPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
