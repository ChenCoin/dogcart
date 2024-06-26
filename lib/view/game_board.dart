import 'package:flutter/material.dart';
import '../data/grid_data.dart';
import 'effect_board.dart';
import 'star_board.dart';

class GameBoard extends StatefulWidget {
  final GridData data;

  final double width;

  final void Function(bool) callback;

  const GameBoard(
      {super.key,
      required this.data,
      required this.width,
      required this.callback});

  @override
  State<StatefulWidget> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    double width = widget.width;
    double height = data.obtainHeight(data.grid);
    var size = Size(width, height);
    return Stack(
      children: [
        SizedBox(
          width: width,
          height: height,
        ),
        Visibility(
          visible: data.gameState.isPlaying(),
          child: RepaintBoundary(
            child: StarBoard(
              size: size,
              data: data,
              callback: widget.callback,
            ),
          ),
        ),
        RepaintBoundary(
          child: Offstage(
            offstage: !data.gameState.isPlaying(),
            child: EffectBoard(
              size: size,
              data: data,
              callback: () => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }
}
