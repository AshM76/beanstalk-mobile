import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget initProfileHeader(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return CustomPaint(
    size: Size(size.width, size.height),
    painter: BackgroundPaint(),
  );
}

class BackgroundPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint();

    Path ovalPath = Path();
    // Start paint
    ovalPath.moveTo(0, 0);
    // draw remaining line to top right side
    ovalPath.lineTo(width, 0);
    // draw remaining line to bottom right side
    ovalPath.lineTo(width, height * 0.23);
    // Paint a curve from current position to bottom left of screen at width * 0.1
    ovalPath.quadraticBezierTo(width * 0.78, height * 0.44, 0, height * 0.28);
    // draw remaining line to bottom left side
    ovalPath.lineTo(0, 0);
    // Close line to reset it back
    ovalPath.close();

    var rect = Offset.zero & size;
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
      colors: AppColor.gradientList,
      stops: [0.3, 0.6, 1],
    ).createShader(rect);

    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
