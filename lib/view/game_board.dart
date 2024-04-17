import 'package:dogcart/data/grid_data.dart';
import 'package:flutter/material.dart';

import 'star_board.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<StatefulWidget> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  GridData data = GridData();

  _GameBoardState() {
    data.start();
    data.printGrids();
  }

  @override
  Widget build(BuildContext context) {
    double width = 422;
    double grid = data.obtainGrid(width);
    double height = data.obtainHeight(grid);
    return SizedBox(
      width: width,
      height: height,
      child: StarBoard(
        size: Size(width, height),
        data: data,
      ),
    );
  }
}
