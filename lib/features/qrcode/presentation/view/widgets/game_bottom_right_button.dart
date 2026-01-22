import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';

class GameBottomRightButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const GameBottomRightButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Button Body
              Container(
                height: 36.h,
                width: 90.w,
                decoration: const BoxDecoration(
                  color: AppColors.buttonYellow,
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyles.font10Secondary700Weight,
                ),
              ),

              // Right Border
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: AppColors.buttonBorderOrange,
                ),
              ),

              // Bottom Border
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: AppColors.buttonBorderOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






