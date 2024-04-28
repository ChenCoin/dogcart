import 'dart:math';

import 'package:flutter/material.dart';

class ColorPoint extends Point<int> {
  int value;

  (int, int) color = (0, 0);

  ColorPoint(super.x, super.y, this.value) {
    color = _colorMap(value);
  }
}

class BreakStarList {
  List<ColorPoint> list;

  Animation<double> anim;

  BreakStarList(this.list, this.anim);
}

class StarGrid {
  int _value = 0;

  (int, int) color = (0, 0);

  bool _movingState = false;

  Point<double> position;

  Point<double> target;

  Animation<double>? anim;

  StarGrid(this.position, this.target);

  void setValue(int value) {
    _value = value;
    color = _colorMap(value);
  }

  void clear() {
    _value = 0;
    color = (0, 0);
    _movingState = false;
    if (anim != null) {
      anim = null;
    }
  }

  void clone(StarGrid other) {
    _value = other._value;
    color = other.color;
    if (other.isMoving()) {
      position = calcPosition(other);
    } else {
      position = other.position;
    }
    anim = null;
  }

  Point<double> calcPosition(StarGrid one) {
    var pos = one.position;
    if (one.anim == null) {
      return pos;
    }
    double animValue = one.anim!.value;
    double dx = pos.x + (one.target.x - pos.x) * animValue / 100;
    double dy = pos.y + (one.target.y - pos.y) * animValue / 100;
    return Point(dx, dy);
  }

  bool isEmpty() {
    return _value == 0;
  }

  bool isNotEmpty() {
    return _value != 0;
  }

  bool isSameColor(StarGrid other) {
    return _value == other._value;
  }

  bool isMoving() {
    return _value != 0 && _movingState;
  }

  void willMove(Animation<double> anim) {
    _movingState = true;
    this.anim = anim;
  }

  void endMove() {
    _movingState = false;
    anim = null;
    position = target;
  }

  void setPosition(Point<double> pos) {
    position = pos;
  }

  Point<double> getPosition() {
    return position;
  }

  void setTarget(int dx, int dy) {
    target = Point(dx.toDouble(), dy.toDouble());
  }

  // this function would remove later
  int getColorValue() {
    return _value;
  }
}

// 颜色匹配
(int, int) _colorMap(int number) {
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
