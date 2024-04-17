import 'package:dogcart/data/grid_data.dart';
import 'package:flutter/material.dart';

import 'star_board.dart';

class GameBoard extends StatefulWidget {
  final GridData data;

  final double width;

  final void Function() callback;

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
    return SizedBox(
      width: width,
      height: height,
      child: StarBoard(
        size: Size(width, height),
        data: data,
        callback: widget.callback,
      ),
    );
  }
}
