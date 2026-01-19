import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';

class GameDrawerIcon extends StatelessWidget {
  const GameDrawerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            width: 60.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              border: Border.all(color: Colors.black, width: 1),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              AppIcons.list,
              height: 18.h,
              width: 26.w,
            ),
          ),
        );
      },
    );
  }
}


