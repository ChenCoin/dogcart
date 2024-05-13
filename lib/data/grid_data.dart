import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ux.dart';
import 'grid_point.dart';

class GridData {
  static const int gap = 4;

  final _random = Random();

  late List<List<StarGrid>> grids = _createList();

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

  // 打破星星动画和移动星星动画的函数
  EffectCreator _effectCreator = NilEffectCreator();

  // 临时调试，后续关卡为, 20500, 24000
  var goals = <int>[1000, 2500, 4000, 5500, 7500, 9000, 11000, 13500, 16500];

  // 游戏状态
  // 0为初始进入游戏
  // 1为游戏中
  // 2为游戏结束(deprecated)
  // 3为游戏中等待下一关
  // 4为游戏结算画面
  // 5为每一关开局动画(deprecated)
  // 6为每一关结束动画(deprecated)
  int gameState = 0;

  double grid = 0;

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    highestScore = prefs.getInt(UX.highestScoreKey) ?? 0;
  }

  void storeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(UX.highestScoreKey, highestScore);
  }

  void start(void Function(VoidCallback) callback) {
    score = 0;
    level = 0;
    onLevelStart(callback);
  }

  void end(void Function(VoidCallback) callback) async {
    if (gameState != 1 && gameState != 3) {
      return;
    }
    onLevelEnd(callback, () {
      gameState = 4;
    });
  }

  void nextLevel(void Function(VoidCallback) callback) {
    level++;
    onLevelStart(callback);
  }

  void onLevelStart(void Function(VoidCallback) callback) {
    goal = queryLevelGoal(level);
    scoreLevel = 0;
    fillGrids();
    _effectCreator.enterScene();
    callback(() => gameState = 1);
  }

  void onViewInit(EffectCreator effectCreator) {
    _effectCreator = effectCreator;
  }

  void onDispose() {
    _effectCreator = NilEffectCreator();
    breakStarList.clear();
  }

  void addBreakStarList(BreakStarList list) {
    breakStarList.add(list);
  }

  void removeBreakStarList(BreakStarList list) {
    breakStarList.remove(list);
  }

  void onLevelFinish(void Function(VoidCallback) callback) {
    onLevelEnd(callback, () {
      if (score >= queryLevelGoal(level)) {
        gameState = 3;
      } else {
        gameState = 4;
      }
    });
  }

  void onLevelEnd(void Function(VoidCallback) callback, VoidCallback next) {
    var starLast = queryStarLast();
    countLastStarAndScore(starLast.length);
    var list = starLast.map((e) => e.toColorPoint()).toList();
    for (var point in list) {
      point.initValue(grid, _random, grids[point.y][point.x].color);
    }
    _effectCreator.exitScene(list);

    highestScore = max(score, highestScore);
    storeData();

    clearGrids();
    callback(() {});
    Future.delayed(const Duration(milliseconds: UX.exitSceneDuration), () {
      breakStarList.clear(); // may error sometime
      callback(next);
    });
  }

  void countLastStarAndScore(int starCount) {
    if (starCount < 10) {
      var scoreMore = 2000 - starCount * starCount * 20;
      scoreLevel += scoreMore;
      score += scoreMore;
    }
  }

  void fillGrids() {
    for (int i = 0; i < UX.row; i++) {
      for (int j = 0; j < UX.col; j++) {
        grids[i][j].setValue(_random.nextInt(5) + 1);
        double dy = i - grid * sqrt(_random.nextDouble()) / 10;
        var pos = Point<double>(j.toDouble(), dy);
        grids[i][j].updatePosition(pos, grid, _random.nextInt(3));
      }
    }
  }

  void clearGrids() {
    for (int i = 0; i < UX.row; i++) {
      for (int j = 0; j < UX.col; j++) {
        grids[i][j].clear();
        grids[i][j].resetPosition();
      }
    }
  }

  void endEnterAnim() {
    for (int i = 0; i < UX.row; i++) {
      for (int j = 0; j < UX.col; j++) {
        grids[i][j].resetPosition();
      }
    }
  }

  int queryLevelGoal(int level) {
    if (level >= goals.length) {
      return goals.last + 2500 * (level - goals.length + 1);
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

  // this function would called before game start
  void initGridSize(double width) {
    grid = (width - (GridData.gap * (UX.col + 1))) / UX.col;
  }

  double obtainHeight(double grid) {
    return grid * UX.row + GridData.gap * (UX.row + 1);
  }

  bool onTap(int dx, int dy) {
    if (dx < 0 || dy < 0 || dx >= UX.col || dy >= UX.row) {
      return false;
    }
    var starGrid = grids[dy][dx];
    if (starGrid.isEmpty()) {
      return false;
    }
    // query the star with same color
    var sameColors = findSameColors(starGrid);
    debugPrint('onTap $dx $dy, num: ${sameColors.length}');
    if (sameColors.length < 2) {
      return false;
    }
    // the tap would cancel when the animation can not work
    if (!_effectCreator.isEffectEnable()) {
      debugPrint('tap cancel as animation running');
      return false;
    }
    // create the animation of break star.
    // mark the star would moved, and create animation.
    for (var point in sameColors) {
      point.initValue(grid, _random, starGrid.color);
    }
    _effectCreator.createEffect(sameColors, brokeGrids(sameColors));
    // count score
    var value = sameColors.length * sameColors.length * 5;
    scoreLevel += value;
    score += value;
    return true;
  }

  // 相连的方块个数大于2，消除方块，并移动剩余方块
  List<StarGrid> brokeGrids(List<Point<int>> sameColors) {
    // 消除相同颜色的方块
    for (var point in sameColors) {
      grids[point.y][point.x].clear();
    }
    List<StarGrid> starWillMove = <StarGrid>[];
    // 方块下落
    for (int i = 0; i < UX.col; i++) {
      int blank = 0;
      for (int j = UX.row - 1; j >= 0; j--) {
        if (grids[j][i].isEmpty()) {
          blank++;
          continue;
        }
        if (blank > 0) {
          grids[j + blank][i].clone(grids[j][i]);
          grids[j][i].clear();
          starWillMove.add(grids[j + blank][i]);
          // [j, i] -> [j + blank, i]
        }
      }
    }
    // 方块左移
    int blank = 0;
    for (int i = 0; i < UX.col; i++) {
      if (grids[UX.row - 1][i].isEmpty()) {
        blank++;
        continue;
      }
      if (blank > 0) {
        for (int j = 0; j < UX.row; j++) {
          if (grids[j][i].isEmpty()) {
            continue;
          }
          grids[j][i - blank].clone(grids[j][i]);
          grids[j][i].clear();
          starWillMove.add(grids[j][i - blank]);
          // [j, i] -> [j, i - blank]
        }
      }
    }
    return starWillMove;
  }

  // 查找与被点击格子相连的相同颜色的格子
  List<ColorPoint> findSameColors(StarGrid starGrid) {
    List<ColorPoint> list = <ColorPoint>[];
    list.add(starGrid.toColorPoint());
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
      var top = ColorPoint(now.x, now.y - 1);
      if (top.y >= 0 && isNewPoint(top)) {
        list.add(top);
      }
      var bottom = ColorPoint(now.x, now.y + 1);
      if (bottom.y < UX.row && isNewPoint(bottom)) {
        list.add(bottom);
      }
      var left = ColorPoint(now.x - 1, now.y);
      if (left.x >= 0 && isNewPoint(left)) {
        list.add(left);
      }
      var right = ColorPoint(now.x + 1, now.y);
      if (right.x < UX.col && isNewPoint(right)) {
        list.add(right);
      }
    }
    return list;
  }

  bool checkIfGameFinish() {
    for (int i = 0; i < UX.row; i++) {
      for (int j = 0; j < UX.col; j++) {
        var gridNow = grids[i][j];
        if (gridNow.isEmpty()) {
          continue;
        }
        if (j != UX.col - 1) {
          var gridRight = grids[i][j + 1];
          if (gridNow.isSameColor(gridRight)) {
            return false;
          }
        }
        if (i != UX.row - 1) {
          var gridBtm = grids[i + 1][j];
          if (gridNow.isSameColor(gridBtm)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  List<StarGrid> queryStarLast() {
    List<StarGrid> result = <StarGrid>[];
    for (int i = 0; i < UX.row; i++) {
      for (int j = 0; j < UX.col; j++) {
        if (grids[i][j].isNotEmpty()) {
          result.add(grids[i][j]);
        }
      }
    }
    return result;
  }

  List<List<StarGrid>> _createList() {
    final List<List<StarGrid>> data = [];
    for (int i = 0; i < UX.row; i++) {
      List<StarGrid> list = [];
      for (int j = 0; j < UX.col; j++) {
        var pos = Point<double>(j.toDouble(), i.toDouble());
        list.add(StarGrid(pos));
      }
      data.add(list);
    }
    return List.unmodifiable(data);
  }

  void printGrids() {
    for (int i = 0; i < UX.row; i++) {
      debugPrint(grids[i].toString());
    }
  }
}

abstract class EffectCreator {
  bool isEffectEnable();

  void createEffect(List<ColorPoint> breakList, List<StarGrid> movingList);

  void enterScene();

  void exitScene(List<ColorPoint> breakList);
}

class NilEffectCreator implements EffectCreator {
  // 没有动画时，游戏逻辑不执行
  @override
  bool isEffectEnable() => false;

  @override
  void createEffect(List<ColorPoint> p, List<StarGrid> g) {}

  @override
  void enterScene() {}

  @override
  void exitScene(List<ColorPoint> b) {}
}
