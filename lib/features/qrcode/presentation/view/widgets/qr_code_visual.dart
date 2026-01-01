import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QrCodeVisual extends StatelessWidget {
  final String qr;

  const QrCodeVisual({super.key, required this.qr});

  @override
  Widget build(BuildContext context) {
    if (qr.isEmpty) {
      return const Center(
        child: Icon(Icons.qr_code, color: Colors.grey, size: 60),
      );
    }

    // Case 1: inline SVG string
    if (qr.contains('<svg')) {
      return SvgPicture.string(
        qr,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    // Case 2: URL (SVG or image)
    if (qr.startsWith('http://') || qr.startsWith('https://')) {
      final isSvg = qr.toLowerCase().contains('.svg');
      if (isSvg) {
        return SvgPicture.network(
          qr,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error, color: Colors.red, size: 40),
          ),
        );
      }
      return Image.network(
        qr,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.red, size: 40),
        ),
      );
    }

    // Unknown format
    return const Center(
      child: Icon(Icons.qr_code, color: Colors.grey, size: 60),
    );
  }
}


