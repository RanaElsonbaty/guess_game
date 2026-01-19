import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';

class ScoreMedalBox extends StatelessWidget {
  final int score;
  final bool isWinner;
  final double size;

  const ScoreMedalBox({
    super.key,
    required this.score,
    required this.isWinner,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Stack(
        children: [
          // Medal icon in top right corner.
          Positioned(
            top: -1,
            right: 3,
            child: SvgPicture.asset(
              isWinner ? AppIcons.goldMedal : AppIcons.silverMedal,
              width: 33.5.w,
              height: 42.w,
            ),
          ),
          // Score display in center (just the number).
          Positioned(
            top: 20.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Text(
                score.toString(),
                style: TextStyles.font32Secondary700Weight,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

