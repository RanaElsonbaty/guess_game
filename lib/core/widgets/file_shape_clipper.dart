import 'package:flutter/material.dart';

class FileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    const double leftHeight = 80;
    const double flatTop = 30;
    const double slopeWidth = 15;
    const double slopeDrop = 30;

    path.moveTo(0, 0);
    path.lineTo(flatTop, 0);
    path.lineTo(flatTop + slopeWidth, slopeDrop);
    path.lineTo(size.width, slopeDrop);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, leftHeight);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
