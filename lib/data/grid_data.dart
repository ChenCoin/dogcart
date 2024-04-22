import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class GridData {
  static const int col = 10;

  static const int row = 10;

  static const int gap = 4;

  List<List<int>> grids = [];

  // 当前分数
  int score = 0;

  // 最高分
  int highestScore = 0;

  // 本局得分
  int scoreLevel = 0;

  // 第几关
  int level = 0;

  // 本局目标分数
  int goal = 0;

  // 临时调试
  var goals = <int>[1000, 2500, 4000, 5500, 7500, 9000, 11000, 13500, 16500, 20500, 24000];

  // 游戏状态，0为初始进入游戏，1为游戏中，2为游戏结束，3为游戏中等待下一关，4为游戏结算画面
  // 状态2已不再使用
  int gameState = 0;

  GridData() {
    for (int i = 0; i < row; i++) {
      List<int> list = [];
      for (int j = 0; j < col; j++) {
        list.add(0);
      }
      grids.add(list);
    }
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    highestScore = prefs.getInt('dogcart.highestScore') ?? 0;
  }

  void storeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('dogcart.highestScore', highestScore);
  }

  void start() {
    gameState = 1;
    score = 0;
    scoreLevel = 0;
    level = 0;
    goal = goals[level];
    fillGrids();
  }

  void end() async {
    gameState = 4;
    highestScore = max(score, highestScore);
    clearGrids();
    storeData();
  }

  void nextLevel() {
    gameState = 1;
    level++;
    goal = queryLevelGoal(level);
    scoreLevel = 0;
    fillGrids();
  }

  void onLevelFinish() {
    var starCount = queryStarLast();
    if (starCount < 10) {
      var scoreMore = 2000 - starCount * starCount * 20;
      scoreLevel += scoreMore;
      score += scoreMore;
    }
    if (score >= queryLevelGoal(level)) {
      gameState = 3;
    } else {
      gameState = 4;
      highestScore = max(score, highestScore);
      storeData();
    }
  }

  void fillGrids() {
    var random = Random();
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        grids[i][j] = random.nextInt(5) + 1;
      }
    }
  }

  void clearGrids() {
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        grids[i][j] = 0;
      }
    }
  }

  int queryLevelGoal(int level) {
    if (level >= goals.length) {
      return goals.last + 3000 * (level - goals.length + 1);
    }
    return goals[level];
  }

  int queryGoalNextLevel() {
    return queryLevelGoal(level + 1);
  }

  bool isGameRunning() {
    return gameState == 1 || gameState == 3;
  }

  bool isGameSettlement() {
    return gameState == 3 || gameState == 4;
  }

  bool isGameWillNextLevel() {
    return gameState == 3;
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
      var value = sameColors.length * sameColors.length * 5;
      scoreLevel += value;
      score += value;
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
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        int colorNow = grids[i][j];
        if (colorNow == 0) {
          continue;
        }
        if (j != col - 1) {
          int colorRight = grids[i][j + 1];
          if (colorNow == colorRight) {
            return false;
          }
        }
        if (i != row - 1) {
          int colorBtm = grids[i + 1][j];
          if (colorNow == colorBtm) {
            return false;
          }
        }
      }
    }
    return true;
  }

  int queryStarLast() {
    int count = 0;
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        if (grids[i][j] != 0) {
          count++;
        }
      }
    }
    return count;
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
