import 'dart:async';
import 'package:dogcart/view/count_down.dart';
import 'package:flutter/material.dart';
import '../data/grid_data.dart';

class LevelPanel extends StatefulWidget {
  final GridData data;

  final void Function() callback;

  const LevelPanel({super.key, required this.data, required this.callback});

  @override
  State<StatefulWidget> createState() {
    return _LevelPanelState();
  }
}

class _LevelPanelState extends State<LevelPanel> {
  static const int levelSecond = 5;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.data.isGameWillNextLevel()) {
      _timer = Timer(const Duration(seconds: levelSecond), widget.callback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      width: 280,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 16)
        ],
      ),
      padding: const EdgeInsets.only(top: 32),
      child: gameContent(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Widget gameContent() {
    if (widget.data.isGameWillNextLevel()) {
      return gameContinue();
    }
    return gameFinish();
  }

  Widget gameContinue() {
    return Column(
      children: [
        const Text(
          '通关',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        Text(
          '本局得分：${widget.data.scoreLevel}',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 18,
          ),
        ),
        const Padding(padding: EdgeInsets.all(16)),
        const Text(
          '下一关',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        Text(
          '目标 ${widget.data.queryGoalNextLevel()}',
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontSize: 18,
          ),
        ),
        const Padding(padding: EdgeInsets.all(4)),
        const TimerText(secondCount: 5),
      ],
    );
  }

  Widget gameFinish() {
    return Column(
      children: [
        const Text(
          '游戏结束',
          style: TextStyle(fontSize: 32),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        Text(
          '本轮游戏得分：${widget.data.score}',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 18,
          ),
        ),
        const Padding(padding: EdgeInsets.all(4)),
        Text(
          '最高得分：${widget.data.highestScore}',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
