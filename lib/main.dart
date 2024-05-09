import 'package:flutter/material.dart';
import 'ux.dart';
import 'view/main_panel.dart';
import 'view/meteor_board.dart';
import 'web/conf_nil.dart' if (dart.library.html) 'web/conf_web.dart';

void main() {
  webConfigure();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) => '收集星星星',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFAFAF8)),
        primaryColor: const Color(0xFFFAFAF8),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFFAFAF8),
        body: Stack(
          children: [
            const MyHomePage(),
            IgnorePointer(child: home(context)),
          ],
        ),
      ),
    );
  }

  Widget home(BuildContext context) {
    return Stack(
      children: [
        if (UX.darkMode)
          Container(decoration: const BoxDecoration(color: Color(0xD0000000))),
        MeteorBoard(size: MediaQuery.of(context).size),
      ],
    );
  }
}
