import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';

class SmallYellowCornerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const SmallYellowCornerButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: (height ?? 36).h,
            width: (width ?? 90).w,
            decoration: const BoxDecoration(
              color: AppColors.buttonYellow,
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyles.font10Secondary700Weight,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2.w,
              color: AppColors.buttonBorderOrange,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2.h,
              color: AppColors.buttonBorderOrange,
            ),
          ),
        ],
      ),
    );
  }
}


