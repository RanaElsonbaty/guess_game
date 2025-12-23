import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/category_card.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';

class LevelsView extends StatelessWidget {
  const LevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 740.w,
          height: 240.h,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              /// Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // stops: const [
                    //   0.07, // نص الهيدر
                    //   0.07,
                    //   0.25,
                    //   0.45,
                    //   0.65,
                    //   0.85,
                    //   1.0,
                    // ],
                    colors: [
                      // Colors.transparent,
                      // AppColors.black.withOpacity(.3),
                      //AppColors.black.withOpacity(.3),
                     // AppColors.black.withOpacity(.3),
                      Color(0XFF8e8e8e),
                      AppColors.black.withOpacity(.2),
                      Colors.white.withOpacity(.5),
                    ],
                  ),
                ),
              ),
              /// Header (painted) INSIDE main container
              Positioned(
                top: -23,
                left: 0,
                child: SizedBox(
                  width: 260.w,
                  height: 80.h,
                  child: CustomPaint(
                    painter: HeaderShapePainter(),
                  ),
                ),
              ),
              Positioned(
                top: -13,
                left: 25,
                child: Text(
                  'الفئات',
                  style: TextStyles.font14Secondary700Weight,
                ),
              ),
              /// Close button (top right of main container)
              Positioned(
                top: -15,
                right: -15,
                child: SvgPicture.asset(AppIcons.cancel
               ),
              ),
              /// Categories container
              Positioned(
                top: 18.h,
                left: 10.w,
                right: 10.w,
                bottom: 20.h,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFF231F20).withOpacity(.3),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 20.h,
                        ),
                        child: const CategoryCard(
                          title: 'الرياضة',
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
