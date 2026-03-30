import 'package:flutter/material.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

Widget initBackgroundPaint(BuildContext context) {
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
    ovalPath.lineTo(width * 0.67, 0);
    // paint a curve from current position to middle of the screen
    ovalPath.quadraticBezierTo(
        width * 0.95, height * 0.30, width * 0.95, height * 0.50);
    // Paint a curve from current position to bottom left of screen at width * 0.1
    ovalPath.quadraticBezierTo(
        width * 0.95, height * 0.80, width * 0.70, height);
    // draw remaining line to bottom left side
    ovalPath.lineTo(0, height);
    // Close line to reset it back
    ovalPath.close();

    var rect = Offset.zero & size;
    paint.shader = AppColor.primaryGradient.createShader(rect);

    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
