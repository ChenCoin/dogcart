import 'dart:math';

class GridData {
  static const int col = 10;

  static const int row = 12;

  static const int gap = 4;

  List<List<int>> grids = [];

  int score = 0;

  int highestScore = 0;

  int gameState = 0;

  // 第几关
  int level = 0;

  GridData() {
    for (int i = 0; i < row; i++) {
      List<int> list = [];
      for (int j = 0; j < col; j++) {
        list.add(0);
      }
      grids.add(list);
    }
  }

  void start() {
    score = 0;
    var random = Random();
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        grids[i][j] = random.nextInt(5) + 1;
      }
    }
  }

  void end() async {
    score = 0;
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        grids[i][j] = 0;
      }
    }
  }

  double obtainGrid(double width) {
    return (width - (GridData.gap * (GridData.col + 1))) / GridData.col;
  }

  double obtainHeight(double grid) {
    return grid * GridData.row + GridData.gap * (GridData.row + 1);
  }

  int onTap(int dx, int dy) {
    if (dy >= row || dx >= col) {
      return 0;
    }
    int color = grids[dy][dx];
    if (color == 0) {
      return 0;
    }
    var sameColors = findSameColors(color, dx, dy);
    if (sameColors.length >= 2) {
      blockGrids(sameColors);
      score += sameColors.length * sameColors.length * 5;
    }
    print('onTap $dx $dy, num: ${sameColors.length}');
    return sameColors.length;
  }

  // 相连的方块个数大于2，消除方块，并移动剩余方块
  void blockGrids(List<Point> sameColors) {
    // 消除相同颜色的方块
    for (var point in sameColors) {
      grids[point.y][point.x] = 0;
    }
    // 方块下落
    for (int i = 0; i < col; i++) {
      int blank = 0;
      for (int j = row - 1; j >= 0; j--) {
        if (blank > 0) {
          grids[j + blank][i] = grids[j][i];
        }
        if (grids[j][i] == 0) {
          blank++;
        } else if (blank > 0) {
          grids[j][i] = 0;
        }
      }
    }
    // 方块左移
    int blank = 0;
    for (int i = 0; i < col; i++) {
      if (grids[row - 1][i] == 0) {
        blank++;
      } else {
        if (blank > 0) {
          for (int j = 0; j < row; j++) {
            grids[j][i - blank] = grids[j][i];
            grids[j][i] = 0;
          }
        }
      }
    }
  }

  // 查找与被点击格子相连的相同颜色的格子
  List<Point> findSameColors(int color, int dx, int dy) {
    List<Point> list = <Point>[];
    list.add(Point(dx, dy));
    isNewPoint(Point point) {
      if (grids[point.y][point.x] != color) {
        return false;
      }
      for (int i = 0; i < list.length; i++) {
        var now = list[i];
        if (now.x == point.x && now.y == point.y) {
          return false;
        }
      }
      return true;
    }

    int index = 0;
    while (index < list.length) {
      var now = list[index];
      index++;
      var top = Point(now.x, now.y - 1);
      if (top.y >= 0 && isNewPoint(top)) {
        list.add(top);
      }
      var bottom = Point(now.x, now.y + 1);
      if (bottom.y < row && isNewPoint(bottom)) {
        list.add(bottom);
      }
      var left = Point(now.x - 1, now.y);
      if (left.x >= 0 && isNewPoint(left)) {
        list.add(left);
      }
      var right = Point(now.x + 1, now.y);
      if (right.x < col && isNewPoint(right)) {
        list.add(right);
      }
    }
    return list;
  }

  bool checkIfGameFinish() {
    for (int i = 0; i < row - 1; i++) {
      for (int j = 0; j < col; j++) {
        int colorNow = grids[i][j];
        if (colorNow == 0) {
          continue;
        }
        int colorRight = grids[i][j + 1];
        int colorBtm = grids[i + 1][j];
        if (colorNow == colorRight || colorNow == colorBtm) {
          return false;
        }
      }
    }
    return true;
  }

  void printGrids() {
    for (int i = 0; i < row; i++) {
      print(grids[i]);
    }
  }
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);
}
