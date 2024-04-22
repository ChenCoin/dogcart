import 'dart:async';

import 'package:flutter/material.dart';

class TimerText extends StatefulWidget {
  final int secondCount;

  const TimerText({super.key, required this.secondCount});

  @override
  State<StatefulWidget> createState() => _TimerTextState();
}

class _TimerTextState extends State<TimerText> {
  int secondCount = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    secondCount = widget.secondCount;
    _timer = Timer.periodic(const Duration(seconds: 1), onTick);
  }

  @override
  Widget build(BuildContext context) {
    return Text('$secondCount 秒后进入下一关');
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void onTick(Timer timer) {
    if (secondCount != 0) {
      setState(() {
        secondCount--;
      });
    }
  }
}
