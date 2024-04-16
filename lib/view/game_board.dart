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
    return SizedBox(
      width: 400,
      height: 400,
      child: StarBoard(
        size: const Size(400, 400),
        data: data,
      ),
    );
  }
}
