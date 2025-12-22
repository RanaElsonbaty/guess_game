import 'package:flutter/material.dart';

class HeaderShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =  RadialGradient(
        center: Alignment.center,
        radius: 0.3,
        colors: [
          Color(0xFF08274C).withOpacity(.3),
          Color(0xFF08274C).withOpacity(.5),
        ],
        stops: [
          0.0,
          1.0,
        ],
      ).createShader(
        Rect.fromLTWH(-85, -25, size.width, size.height),
      );

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - 180, 0)
      ..lineTo(size.width-135, size.height / 4)
      ..lineTo(size.width - 155, size.height-60)
      ..lineTo(0, size.height-60)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
