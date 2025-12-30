import 'package:flutter/material.dart';

class HeaderShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Start from top-left
    path.moveTo(0, 0);

    // Top line to top-right
    path.lineTo(size.width, 0);

    // Right line down
    path.lineTo(size.width, size.height * 0.7);

    // Curve to bottom-left
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      0,
      size.height * 0.7,
    );

    // Close the path
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


