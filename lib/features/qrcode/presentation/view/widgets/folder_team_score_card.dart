import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/file_shape_clipper.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/score_medal_box.dart';

class FolderTeamScoreCard extends StatelessWidget {
  final String teamTitle;
  final int score;
  final bool isWinner;
  final bool isLoser;
  final double width;
  final double height;

  const FolderTeamScoreCard({
    super.key,
    required this.teamTitle,
    required this.score,
    this.isWinner = false,
    this.isLoser = false,
    this.width = 237,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FileClipper(),
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0XFF8e8e8e),
              AppColors.black.withOpacity(.3),
              Colors.white.withOpacity(.5),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 35.h, bottom: 12.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Column(
              children: [
                Text(teamTitle, style: TextStyles.font14Secondary700Weight),
                SizedBox(height: 10.h),
                Expanded(
                  child: Center(
                    child: ScoreMedalBox(score: score, isWinner: isWinner),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
