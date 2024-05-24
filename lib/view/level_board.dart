import 'dart:async';
import 'package:flutter/material.dart';
import '../content.dart';
import '../data/grid_data.dart';
import '../ux.dart';
import 'count_down.dart';

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
          BoxShadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 8)
        ],
      ),
      padding: const EdgeInsets.only(top: 16),
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
    int breakStar = UX.row * UX.col - widget.data.lastStarCount;
    int lastStarCount = widget.data.lastStarCount;
    int lastStarScore = 2000 - lastStarCount * lastStarCount * 20;
    int score = widget.data.scoreLevel - lastStarScore;
    return Column(
      children: [
        const Text(
          Content.pass,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        Text(
          Content.level_score(widget.data.scoreLevel),
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 18,
          ),
        ),
        Text(
          Content.collect_star(breakStar, score),
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 18,
          ),
        ),
        Text(
          Content.last_star(lastStarCount, lastStarScore),
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 18,
          ),
        ),
        const Padding(padding: EdgeInsets.all(16)),
        const Text(
          Content.next_level,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        Text(
          Content.target(widget.data.queryGoalNextLevel()),
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontSize: 18,
          ),
        ),
        const Padding(padding: EdgeInsets.all(4)),
        const TimerText(secondCount: levelSecond),
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
        const Padding(padding: EdgeInsets.all(32)),
        ElevatedButton(
          onPressed: () {
            widget.data.gameState.backHome();
            widget.callback();
          },
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(200, 48)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24))),
              backgroundColor: MaterialStateProperty.all(Colors.amber)),
          child: const Padding(
            padding: EdgeInsets.only(left: 8, top: 2, right: 8, bottom: 6),
            child: Text(
              '回到首页',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        TextButton(
          onPressed: () => widget.callback(),
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(100, 32))),
          child: const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Text(
              '重新开始',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
