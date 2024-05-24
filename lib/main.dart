import 'package:flutter/material.dart';
import 'content.dart';
import 'ux.dart';
import 'view/background.dart';
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
      onGenerateTitle: (ctx) => Content.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFAFAF8)),
        primaryColor: const Color(0xFFFAFAF8),
        useMaterial3: true,
        fontFamily: 'harmony'
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFFAFAF8),
        body: Stack(
          children: [
            IgnorePointer(child: home(context)),
            const MyHomePage(),
          ],
        ),
      ),
    );
  }

  Widget home(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        BackgroundBoard(size: size),
        MeteorBoard(size: size),
        if (UX.darkMode)
          Container(decoration: const BoxDecoration(color: Color(0xD0000000))),
      ],
    );
  }
}
