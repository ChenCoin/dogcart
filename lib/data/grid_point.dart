class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) {
    return other is Point && x == other.x && y == other.y;
  }

  @override
  int get hashCode => x * x + y * y + y;
}

class MovingPoint {
  Point src;
  Point target;

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

  void willMove(Point src) {
    _movingState = true;
  }

  void willMoveDirect() {
    _movingState = true;
  }

  void endMove() {
    _movingState = false;
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
}
