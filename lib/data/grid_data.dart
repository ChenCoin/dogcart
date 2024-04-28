import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'grid_point.dart';

class GridData {
  static const int col = 10;

  static const int row = 10;

  static const int gap = 4;

  List<List<StarGrid>> grids = [];

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

  // 打破星星的动画列表
  List<BreakStarList> breakStarList = <BreakStarList>[];

  // 打破星星动画函数
  void Function(List<ColorPoint>) breakFn = (arg) {};

  // 移动星星动画函数
  void Function(List<StarGrid>) movingFn = (arg) {};

  // 临时调试
  var goals = <int>[
    1000,
    2500,
    4000,
    5500,
    7500,
    9000,
    11000,
    13500,
    16500,
    20500,
    24000
  ];

  // 游戏状态，0为初始进入游戏，1为游戏中，2为游戏结束，3为游戏中等待下一关，4为游戏结算画面
  // 状态2已不再使用
  int gameState = 0;

  GridData() {
    for (int i = 0; i < row; i++) {
      List<StarGrid> list = [];
      for (int j = 0; j < col; j++) {
        var pos = Point<double>(j.toDouble(), i.toDouble());
        list.add(StarGrid(pos, pos));
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
    onDispose();
  }

  void onViewInit(void Function(List<ColorPoint>) breakFn,
      void Function(List<StarGrid>) movingFn) {
    this.breakFn = breakFn;
    this.movingFn = movingFn;
  }

  void onDispose() {
    breakFn = (arg) {};
    movingFn = (arg) {};
    breakStarList.clear();
  }

  void addBreakStarList(BreakStarList list) {
    breakStarList.add(list);
  }

  void removeBreakStarList(BreakStarList list) {
    breakStarList.remove(list);
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
        grids[i][j].setValue(random.nextInt(5) + 1);
      }
    }
  }

  void clearGrids() {
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        grids[i][j].clear();
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
    var starGrid = grids[dy][dx];
    if (starGrid.isEmpty()) {
      return 0;
    }
    var sameColors = findSameColors(starGrid, dx, dy, starGrid.getColorValue());
    if (sameColors.length >= 2) {
      // 创建动画
      breakFn(sameColors);
      blockGrids(sameColors);
      var value = sameColors.length * sameColors.length * 5;
      scoreLevel += value;
      score += value;
    }
    debugPrint('onTap $dx $dy, num: ${sameColors.length}');
    return sameColors.length;
  }

  // 相连的方块个数大于2，消除方块，并移动剩余方块
  void blockGrids(List<Point<int>> sameColors) {
    // 消除相同颜色的方块
    for (var point in sameColors) {
      grids[point.y][point.x].clear();
    }
    List<StarGrid> starWillMove = <StarGrid>[];
    // 方块下落
    for (int i = 0; i < col; i++) {
      int blank = 0;
      for (int j = row - 1; j >= 0; j--) {
        if (grids[j][i].isEmpty()) {
          blank++;
          continue;
        }
        if (blank > 0) {
          grids[j + blank][i].clone(grids[j][i]);
          grids[j + blank][i].setTarget(i, j + blank);
          grids[j][i].clear();
          starWillMove.add(grids[j + blank][i]);
          // [j, i] -> [j + blank, i]
        }
      }
    }
    // 方块左移
    int blank = 0;
    for (int i = 0; i < col; i++) {
      if (grids[row - 1][i].isEmpty()) {
        blank++;
        continue;
      }
      if (blank > 0) {
        for (int j = 0; j < row; j++) {
          if (grids[j][i].isEmpty()) {
            continue;
          }
          grids[j][i - blank].clone(grids[j][i]);
          grids[j][i - blank].setTarget(i - blank, j);
          grids[j][i].clear();
          starWillMove.add(grids[j][i - blank]);
          // [j, i] -> [j, i - blank]
        }
      }
    }
    for (var item in starWillMove) {
      debugPrint(
          'move [${item.position.x}, ${item.position.y}] -> [${item.target.x}, ${item.target.y}]');
    }
    movingFn(starWillMove);
  }

  // 查找与被点击格子相连的相同颜色的格子
  List<ColorPoint> findSameColors(
      StarGrid starGrid, int dx, int dy, int color) {
    List<ColorPoint> list = <ColorPoint>[];
    list.add(ColorPoint(dx, dy, color));
    isNewPoint(Point<int> point) {
      if (!grids[point.y][point.x].isSameColor(starGrid)) {
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
      var top = ColorPoint(now.x, now.y - 1, color);
      if (top.y >= 0 && isNewPoint(top)) {
        list.add(top);
      }
      var bottom = ColorPoint(now.x, now.y + 1, color);
      if (bottom.y < row && isNewPoint(bottom)) {
        list.add(bottom);
      }
      var left = ColorPoint(now.x - 1, now.y, color);
      if (left.x >= 0 && isNewPoint(left)) {
        list.add(left);
      }
      var right = ColorPoint(now.x + 1, now.y, color);
      if (right.x < col && isNewPoint(right)) {
        list.add(right);
      }
    }
    return list;
  }

  bool checkIfGameFinish() {
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        var gridNow = grids[i][j];
        if (gridNow.isEmpty()) {
          continue;
        }
        if (j != col - 1) {
          var gridRight = grids[i][j + 1];
          if (gridNow.isSameColor(gridRight)) {
            return false;
          }
        }
        if (i != row - 1) {
          var gridBtm = grids[i + 1][j];
          if (gridNow.isSameColor(gridBtm)) {
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
        if (grids[i][j].isNotEmpty()) {
          count++;
        }
      }
    }
    return count;
  }

  void printGrids() {
    for (int i = 0; i < row; i++) {
      debugPrint(grids[i].toString());
    }
  }
}
