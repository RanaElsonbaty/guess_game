import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/images.dart';

class LogoSection extends StatelessWidget {
  final BoxConstraints constraints;

  const LogoSection({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    // Logo size based on screen height (landscape mode)
    final logoSize = constraints.maxHeight * 0.35;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 112.w,
        minHeight: 112.h,
        maxWidth: 126.w,
        maxHeight: 126.h,
      ),
      child: Image.asset(
        AppImages.logo,
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
