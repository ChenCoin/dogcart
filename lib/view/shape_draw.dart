import 'dart:math';
import 'dart:ui';

// 绘制五角星
Path drawStar(double R, double r, double dx, double dy, double rot) {
  // 五角星的角度
  deg2Rad(int i) => (36 * i - rot) / 180 * pi;
  Path path = Path();
  path.moveTo(dx, dy - R);
  // 沿着10个点绘制路径
  for (int i = 1; i <= 10; i++) {
    double rad = i % 2 == 1 ? r : R;
    double posX = dx - sin(deg2Rad(i)) * rad;
    double posY = dy - cos(deg2Rad(i)) * rad;
    path.lineTo(posX, posY);
  }
  path.close();
  return path;
}

// 绘制平滑的圆角矩形
Path drawSmoothRoundRect(
    double left, double top, double width, double height, double radius) {
  int n = 4;
  double gap = radius / n;
  double right = left + width;
  double btm = top + height;
  Path path = Path();
  path.moveTo(left, top + radius);
  path.cubicTo(left, top + gap, left + gap, top, left + radius, top);
  path.lineTo(right - radius, top);
  path.cubicTo(right - gap, top, right, top + gap, right, top + radius);
  path.lineTo(right, btm - radius);
  path.cubicTo(right, btm - gap, right - gap, btm, right - radius, btm);
  path.lineTo(left + radius, btm);
  path.cubicTo(left + gap, btm, left, btm - gap, left, btm - radius);
  path.close();
  return path;
}
