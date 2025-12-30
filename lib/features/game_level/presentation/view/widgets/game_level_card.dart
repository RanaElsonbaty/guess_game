import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/file_shape_clipper.dart';

class GameLevelCard extends StatefulWidget {
  final String teamName;
  final String teamTitle;
  final Function(String) onLevelSelected;

  const GameLevelCard({
    super.key,
    required this.teamName,
    required this.teamTitle,
    required this.onLevelSelected,
  });

  @override
  State<GameLevelCard> createState() => _GameLevelCardState();
}

class _GameLevelCardState extends State<GameLevelCard> {
  String? selectedLevel;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FileClipper(),
      child: Container(
        width: 237.w,
        height: 240.h,
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
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 35.h),
          child: Column(
            children: [
              Text(
                widget.teamTitle,
                style: TextStyles.font14Secondary700Weight,
              ),
              SizedBox(height: 25.h),
              // Ball Icon
              Image.asset(AppImages.ball,height: 50.h,width: 50.w,),
              SizedBox(height: 25.h),
              // Level Options (Small Cards)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLevelOption('سهل', '200'),
                  _buildLevelOption('صعب', '400'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelOption(String title, String points) {
    final isSelected = selectedLevel == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = title;
        });
        widget.onLevelSelected(title);
      },
      child: Stack(
        children: [
          Container(
            width: 80.w,
            height: 60.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ Color(0xFF79899f),Color(0xFF8b929b), Color(0xFF79899f)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Container(
                  height: 25,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.card),
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: Text(
                    title,
                    style: TextStyles.font14Secondary700Weight,
                  ),
                ),

                // Points
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    '$points نقطة',
                    style: TextStyles.font14Secondary700Weight,
                  ),
                ),
              ],
            ),
          ),

          // Selection border overlay
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondaryColor,
                    width: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
