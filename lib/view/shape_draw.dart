import 'dart:math';

import 'package:flutter/material.dart';

import '../data/grid_data.dart';
import '../data/grid_point.dart';
import '../ux.dart';

// 绘制五角星，rot为角度，最大为360
void drawStar(Path path, double R, double r, double dx, double dy, double rot) {
  // 五角星的角度
  deg2Rad(int i) => (36 * i - rot) / 180 * pi;
  path.reset();
  path.moveTo(dx - sin(deg2Rad(10)) * R, dy - cos(deg2Rad(10)) * R);
  // 沿着10个点绘制路径
  for (int i = 1; i <= 10; i++) {
    double rad = i % 2 == 1 ? r : R;
    double posX = dx - sin(deg2Rad(i)) * rad;
    double posY = dy - cos(deg2Rad(i)) * rad;
    path.lineTo(posX, posY);
  }
  path.close();
}

// 绘制平滑的圆角矩形
void drawSmoothRoundRect(Path path, double left, double top, double width,
    double height, double radius) {
  int n = 4;
  double gap = radius / n;
  double right = left + width;
  double btm = top + height;
  path.reset();
  path.moveTo(left, top + radius);
  path.cubicTo(left, top + gap, left + gap, top, left + radius, top);
  path.lineTo(right - radius, top);
  path.cubicTo(right - gap, top, right, top + gap, right, top + radius);
  path.lineTo(right, btm - radius);
  path.cubicTo(right, btm - gap, right - gap, btm, right - radius, btm);
  path.lineTo(left + radius, btm);
  path.cubicTo(left + gap, btm, left, btm - gap, left, btm - radius);
  path.close();
}

void drawMovingStar(
    Canvas canvas, GridData data, Path path, Paint gridPaint, Paint starPaint) {
  int gap = GridData.gap;
  double grid = data.grid;
  // draw grids
  for (int dy = 0; dy < UX.row; dy++) {
    for (int dx = 0; dx < UX.col; dx++) {
      var gridPoint = data.grids[dy][dx];
      if (!gridPoint.isMoving()) {
        continue;
      }
      var anim = gridPoint.anim?.value ?? 0;
      if (gridPoint.animFlag == 1) {
        anim = 100;
      }
      if (gridPoint.animFlag == 2) {
        if (anim < 50) {
          continue;
        }
        anim = (anim - 50) * 2;
      }

      var posY = gridPoint.getPosition().y;
      var i = posY + (dy - posY) * anim / 100;
      var posX = gridPoint.getPosition().x;
      var j = posX + (dx - posX) * anim / 100;

      (int, int) color = gridPoint.color;
      gridPaint.color = Color(color.$2);
      starPaint.color = Color(color.$1);

      // draw round grid
      var left = grid * j + gap * (j + 1);
      var top = grid * i + gap * (i + 1);
      drawSmoothRoundRect(path, left, top, grid, grid, 12);
      canvas.drawPath(path, gridPaint);

      // draw star
      left = left + grid / 2;
      top = top + grid / 2;
      drawStar(path, grid / 2 - 2, grid / 4, left, top, 0);
      canvas.drawShadow(path, const Color(0xFF808080), 3, false);
      canvas.drawPath(path, starPaint);
    }
  }
}

void drawBreakStar(Canvas canvas, GridData data, Path path, Paint starPaint) {
  double grid = data.grid;
  List<BreakStarList> breakStars = data.breakStarList;
  for (var item in breakStars) {
    Animation<double> anim = item.anim;
    if (anim.status != AnimationStatus.forward) {
      continue;
    }
    List<ColorPoint> list = item.list;
    for (var colorPoint in list) {
      // draw star
      var animValue = 100 - anim.value / 2; // 100 -> 50
      double R = (grid / 2 - 2) * animValue / 100;
      double r = (grid / 4) * animValue / 100;
      var rot = 360 * anim.value / 100;
      int alpha = 255 * (100 - anim.value) ~/ 100;
      int color = colorPoint.color.$1;
      starPaint.color = Color(color).withAlpha(alpha);

      for (var end in colorPoint.probability) {
        var dx = colorPoint.start.$1 + end.$1 * anim.value / 100;
        var dy = colorPoint.start.$2 + end.$2 * anim.value / 100;
        drawStar(path, R, r, dx, dy, rot);
        canvas.drawPath(path, starPaint);
      }
    }
  }
}
