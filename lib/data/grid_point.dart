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

class MovingPoint {
  Point<int> src;
  Point<int> target;

  MovingPoint(this.src, this.target);
}

class StarGrid {
  int _value = 0;

  (int, int) color = (0, 0);

  bool _movingState = false;

  void setValue(int value) {
    _value = value;
    color = _colorMap(value);
  }

  void clear() {
    _value = 0;
    color = (0, 0);
    _movingState = false;
  }

  void clone(StarGrid other) {
    _value = other._value;
    color = other.color;
    _movingState = other._movingState;
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
    return _movingState;
  }

  void willMove(Point<int> src) {
    _movingState = true;
  }

  void willMoveDirect() {
    _movingState = true;
  }

  void endMove() {
    _movingState = false;
  }

  int getColorValue() {
    return _value;
  }
}

class MovingStar {
  Point<double> src;

  Point<double> target;

  StarGrid grid;

  MovingStar(this.src, this.target, this.grid);
}

class MovingStarList {
  List<MovingStar> list;

  Animation<double> anim;

  MovingStarList(this.list, this.anim);
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
