import 'package:flutter/material.dart';

class HeaderShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.3,
        colors: [
          Color(0xFF668899),
          Color(0XFF617685),
        ],
        stops: [
          0.0,
          1.0,
        ],
      ).createShader(
        Rect.fromLTWH(-size.width * 0.3, -size.height * 0.3, size.width, size.height),
      );

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.37, 0) // 37% من العرض
      ..lineTo(size.width * 0.53, size.height * 0.25) // 53% من العرض، 25% من الارتفاع
      ..lineTo(size.width * 0.46, size.height * 0.25) // 46% من العرض، 25% من الارتفاع
      ..lineTo(0, size.height * 0.25) // 25% من الارتفاع
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
