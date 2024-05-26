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
                  fontSize: 84,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'pig',
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 12
                    ..color = Colors.amber),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 84,
                fontWeight: FontWeight.bold,
                fontFamily: 'pig',
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.all(96)),
        ElevatedButton(
          onPressed: () => _onBtnTap(),
          style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size(180, 54)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24))),
              backgroundColor: WidgetStateProperty.all(Colors.amber)),
          child: const Text(
            Content.startGame,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            Content.theHighestScore(data.highestScore),
            style: const TextStyle(color: Colors.white),
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
                  text: Content.score,
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
              Content.levelAndGoal(data.level + 1, data.goal),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ] else ...[
          const Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              Content.gameTip,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  String _gameStateBtnLabel(BuildContext context) {
    if (data.gameState.isRunning()) {
      return Content.endGame;
    }
    if (data.gameState.isGameSettlement()) {
      return Content.playAgain;
    }
    return Content.startGame;
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
