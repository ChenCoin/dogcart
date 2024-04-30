import 'dart:math';
import 'package:flutter/material.dart';

// 绘制五角星
void drawStar(Path path, double R, double r, double dx, double dy, double rot) {
  // 五角星的角度
  deg2Rad(int i) => (36 * i - rot) / 180 * pi;
  path.reset();
  path.moveTo(dx, dy - R);
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

class NumberDrawer {
  static const double fontSize = 24;

  final paint = TextPainter()
    ..textAlign = TextAlign.center
    ..textDirection = TextDirection.ltr;

  final style = const TextStyle(
    color: Colors.yellow,
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
  );

  void drawNumber(Canvas canvas, double dx, double dy, String text) {
    // 画数字
    paint.text = TextSpan(text: text, style: style);
    paint.layout(minWidth: 60);
    paint.paint(canvas, Offset(dx - 30, dy));
  }
}