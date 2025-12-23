import 'package:flutter/material.dart';
import 'package:guess_game/core/widgets/file_shape_clipper.dart';

class FileShapePainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;

  FileShapePainter({
    required this.borderColor,
    required this.borderWidth,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = FileClipper().getClip(size);

    // 🔹 Shadow
    canvas.drawShadow(
      path,
      shadowColor,
      6,
      false,
    );

    // 🔹 Border
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
