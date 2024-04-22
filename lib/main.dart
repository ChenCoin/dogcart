import 'dart:math';

import 'package:dogcart/data/grid_data.dart';
import 'package:dogcart/view/game_board.dart';
import 'package:dogcart/view/level_board.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) => '消灭星星',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFAFAF8)),
        primaryColor: const Color(0xFFFAFAF8),
        useMaterial3: true,
      ),
      supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GridData data = GridData();

  void _onBtnTap() {
    if (data.gameState == 0 || data.gameState == 4) {
      data.start();
      return;
    }
    data.end();
  }

  void _onStateChange(bool isFinish) {
    if (isFinish) {
      data.onLevelFinish();
    }
  }

  void _onLevelNext() {
    data.nextLevel();
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: Align(
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
                    callback: () => setState(() {
                      _onLevelNext();
                    }),
                  ),
                ]
              ],
            ),
            btnOnBottom(),
          ],
        ),
      ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(highestScoreTip()),
          ),
        ],
      ],
    );
  }

  String highestScoreTip() {
    if (data.highestScore == 0) {
      return '消除连在一起的相同颜色的星星。';
    }
    return '消除相同颜色的星星。最高分：${data.highestScore}';
  }

  String _gameStateBtnLabel(BuildContext context) {
    if (data.gameState == 1 || data.gameState == 3) {
      return '结束';
    }
    if (data.gameState == 4) {
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
          onPressed: () => setState(() {
            _onBtnTap();
          }),
          child: Text(
            _gameStateBtnLabel(context),
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
