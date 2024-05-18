import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../content.dart';
import '../data/grid_data.dart';
import '../ux.dart';
import 'game_board.dart';
import 'level_board.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GridData data = GridData();

  void _onBtnTap() {
    if (!data.gameState.isRunning()) {
      data.start(setState);
      return;
    }
    data.end(setState);
  }

  void _onLevelFinish() {
    data.onLevelFinish(setState);
  }

  void _onStateChange(bool isFinish) {
    if (isFinish) {
      int animDuration = max(UX.breakStarDuration, UX.moveStarDuration);
      var duration = Duration(milliseconds: animDuration);
      Future.delayed(duration, _onLevelFinish);
    }
  }

  void _onLevelNext() {
    if (data.gameState.isGameOver()) {
      data.start(setState);
      return;
    }
    if (data.gameState.isHome()) {
      setState(() {});
      return;
    }
    if (!data.isGameRunning()) {
      return;
    }
    data.nextLevel(setState);
  }

  @override
  void initState() {
    super.initState();
    data.init();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // 宽度为屏幕宽度 - 40，特殊适配大屏
    final double width = min(screenSize.width - 12, 480);
    data.initGridSize(width);
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: width - 12,
                height: 72,
                child: titleOnPanel(),
              ),
              const Padding(padding: EdgeInsets.all(4)),
              Stack(
                alignment: Alignment.center,
                children: [
                  GameBoard(
                    data: data,
                    width: width,
                    callback: (isFinish) => setState(() {
                      _onStateChange(isFinish);
                    }),
                  ),
                  if (data.isGameSettlement()) ...[
                    LevelPanel(
                      data: data,
                      callback: _onLevelNext,
                    ),
                  ]
                ],
              ),
              if (data.gameState.isRunning()) btnOnBottom(),
            ],
          ),
        ),
        if (data.gameState.isHome()) homePage(),
      ],
    );
  }

  Widget homePage() {
    String title = Content.title;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.all(48)),
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 10
                    ..color = Colors.amber),
            ),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.all(96)),
        ElevatedButton(
          onPressed: () => _onBtnTap(),
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24))),
              backgroundColor: MaterialStateProperty.all(Colors.amber)),
          child: const Padding(
            padding: EdgeInsets.only(left: 16, top: 6, right: 16, bottom: 8),
            child: Text(
              Content.startGame,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '最高分: ${data.highestScore}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget titleOnPanel() {
    return Stack(
      children: [
        if (data.isGameRunning()) ...[
          Align(
            alignment: Alignment.bottomLeft,
            child: Text.rich(TextSpan(
              children: [
                const TextSpan(
                  text: "分数: ",
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
                TextSpan(
                  text: "${data.score}",
                  style: const TextStyle(color: Colors.amber, fontSize: 20),
                )
              ],
            )),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '关卡: ${data.level + 1}  目标: ${data.goal}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ] else ...[
          const Align(
            alignment: Alignment.bottomCenter,
            child: Text('消除连在一起的相同颜色的星星。'),
          ),
        ],
      ],
    );
  }

  String _gameStateBtnLabel(BuildContext context) {
    if (data.gameState.isRunning()) {
      return '结束';
    }
    if (data.gameState.isGameSettlement()) {
      return '再次挑战';
    }
    return '开始游戏';
  }

  Widget btnOnBottom() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 160,
        height: 42,
        child: FilledButton(
          onPressed: _onBtnTap,
          child: Text(
            _gameStateBtnLabel(context),
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
