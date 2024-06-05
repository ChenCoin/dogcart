import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';

import '../content.dart';

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 640),
        child: arcTitle(context),
      ),
    );
  }

  Widget arcTitle(BuildContext context) {
    const title = Content.title;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ArcText(
          text: title,
          textStyle: TextStyle(
              fontSize: 84,
              fontWeight: FontWeight.bold,
              fontFamily: 'pig',
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 12
                ..color = Colors.amber),
          radius: 450,
          startAngle: 0,
          startAngleAlignment: StartAngleAlignment.center,
          placement: Placement.outside,
          direction: Direction.clockwise,
        ),
        const ArcText(
          text: title,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 84,
            fontWeight: FontWeight.bold,
            fontFamily: 'pig',
          ),
          radius: 450,
          startAngle: 0,
          startAngleAlignment: StartAngleAlignment.center,
          placement: Placement.outside,
          direction: Direction.clockwise,
        ),
      ],
    );
  }
}
