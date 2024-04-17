import 'dart:math';

import 'package:dogcart/data/grid_data.dart';
import 'package:dogcart/view/game_board.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white60),
        primaryColor: Colors.white60,
        useMaterial3: true,
      ),
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

  void _startGame() {
    setState(() {
      data.start();
    });
  }

  void _endGame() {
    setState(() {
      data.end();
    });
  }

  void _onBtnTap() {
    if (data.gameState == 0) {
      data.gameState = 1;
      _startGame();
      return;
    }
    if (data.gameState == 1) {
      data.gameState = 2;
      _endGame();
      return;
    }
    if (data.gameState == 2) {
      data.gameState = 1;
      _startGame();
    }
  }

  void _onStateChange(bool isFinish) {
    if (isFinish) {

    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // 宽度为屏幕宽度 - 40，特殊适配大屏
    final double width = min(screenSize.width - 32, 422);
    double height = width / 10 * 16;
    return Scaffold(
      backgroundColor: Colors.white60,
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: width - 16,
              height: 84,
              child: Stack(
                children: [
                  if (data.gameState == 1) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '第 ${data.level + 1} 关 ',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '分数: ${data.score}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(8)),
                  ],
                ],
              ),
            ),
            GameBoard(
              data: data,
              width: width,
              callback: _onStateChange,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 160,
                height: 42,
                child: FilledButton(
                  onPressed: _onBtnTap,
                  child: Text(
                    data.gameState != 1 ? '开始游戏' : '结束',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
