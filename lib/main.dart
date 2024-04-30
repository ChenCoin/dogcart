import 'package:flutter/material.dart';
import 'ux.dart';
import 'view/main_panel.dart';
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
      home: Scaffold(backgroundColor: const Color(0xFFFAFAF8), body: home()),
    );
  }

  Widget home() {
    if (UX.debugMode) {
      return Stack(
        children: [
          const MyHomePage(),
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xD0000000)),
            ),
          ),
        ],
      );
    } else {
      return const MyHomePage();
    }
  }
}
