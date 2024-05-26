// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dogcart/content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  debugPrint('test start');
  var textContent = '0123456789';
  textContent += 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
  textContent += Content.startGame;
  textContent += Content.goToNextLevel(0);
  textContent += Content.pass;
  textContent += Content.levelScore(0);
  textContent += Content.collectStar(0, 0);
  textContent += Content.lastStar(0, 0);
  textContent += Content.nextLevel;
  textContent += Content.target(0);
  textContent += Content.gameOver;
  textContent += Content.gameScore(0);
  textContent += Content.highestScore(0);
  textContent += Content.backHome;
  textContent += Content.restart;
  textContent += Content.theHighestScore(0);
  textContent += Content.score;
  textContent += Content.levelAndGoal(0, 0);
  textContent += Content.gameTip;
  textContent += Content.endGame;
  textContent += Content.playAgain;
  debugPrint(textContent.characters.toSet().reduce((a, b) => a + b));
  debugPrint('test end');
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {});
}
