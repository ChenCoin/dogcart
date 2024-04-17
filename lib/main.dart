import 'dart:math';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8A9CA0)),
        primaryColor: const Color(0xFF8A9CA0),
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
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // 宽度为屏幕宽度 - 40，特殊适配大屏
    final double width = min(screenSize.width - 32, 400);
    double height = width / 10 * 16;
    return const Scaffold(
      backgroundColor: Color(0xFF8A9CA0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times',
            ),
            GameBoard(),
          ],
        ),
      ),
    );
  }
}
