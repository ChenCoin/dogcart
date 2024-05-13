import 'dart:math';

import 'package:flutter/material.dart';

import 'grid_data.dart';

class ColorPoint extends Point<int> {
  (int, int) color = (0, 0);

  (double, double) start = (0, 0);

  (double, double) end = (0, 0);

  List<(double, double)> probability = <(double, double)>[];

  ColorPoint(super.x, super.y);

  void initValue(double grid, Random random, (int, int) color) {
    double left = grid * x + GridData.gap * (x + 1);
    double top = grid * y + GridData.gap * (y + 1);
    start = (left + grid / 2, top + grid / 2);
    probability.clear();
    var max = random.nextInt(3);
    for (var i = 0; i < max + 1; i++) {
      probability.add(createEndPoint(grid, random));
    }
    this.color = color;
  }

  (double, double) createEndPoint(double grid, Random random) {
    var angle = 360 * random.nextDouble();
    return (grid * 2 * sin(angle), grid * 2 * cos(angle));
  }
}

class BreakStarList {
  List<ColorPoint> list;

  Animation<double> anim;

  BreakStarList(this.list, this.anim);
}

class StarGrid {
  // the position of star is a static value, it init when the object was new
  final Point<double> _location;

  // the position of star. when moving, it would from _position to _location
  Point<double> _position = const Point<double>(0, 0);

  int _value = 0;

  (int, int) color = (0, 0);

  bool _movingState = false;

  Animation<double>? anim;

  // cache the left of static grids
  double left = 0;

  // cache the top of static grids
  double top = 0;

  StarGrid(this._location);

  void setValue(int value) {
    _value = value;
    color = _colorMap(value);
  }

  void clear() {
    _value = 0;
    color = (0, 0);
    _movingState = false;
    anim = null;
  }

  void clone(StarGrid other) {
    _value = other._value;
    color = other.color;
    if (other.isMoving()) {
      _position = calcPosition(other);
    } else {
      _position = other._position;
    }
    anim = null;
  }

  Point<double> calcPosition(StarGrid one) {
    var pos = one._position;
    if (one.anim == null) {
      return pos;
    }
    double animValue = one.anim!.value;
    double dx = pos.x + (one._location.x - pos.x) * animValue / 100;
    double dy = pos.y + (one._location.y - pos.y) * animValue / 100;
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
    _position = _location;
  }

  // refresh the position of star when level start
  void updatePosition(Point<double> pos, double grid) {
    _position = pos;
    _movingState = true;
    left = grid * _location.x + GridData.gap * (_location.x + 1);
    top = grid * _location.y + GridData.gap * (_location.y + 1);
  }

  void resetPosition() {
    _movingState = false;
    _position = _location;
  }

  Point<double> getPosition() {
    return _position;
  }

  ColorPoint toColorPoint() {
    return ColorPoint(_location.x.toInt(), _location.y.toInt());
  }
}

// color map
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
