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
    double grid = data.obtainGrid(width);
    double height = data.obtainHeight(grid);
    return Stack(
      children: [
        RepaintBoundary(
          child: StarBoard(
            size: Size(width, height),
            data: data,
            callback: widget.callback,
          ),
        ),
        Offstage(
          offstage: data.gameState != 1,
          child: RepaintBoundary(
            child: EffectBoard(
              size: Size(width, height),
              data: data,
              callback: () => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }
}
