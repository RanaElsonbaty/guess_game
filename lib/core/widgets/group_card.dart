import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/file_shape_clipper.dart';

class GroupCard extends StatelessWidget {
  final String title;

  const GroupCard({super.key, required this.title});

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
          padding: EdgeInsets.only(left: 10.w,right:10.w,top: 35.h),

          /// 👇 inner clipped container
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0XFF231F20).withOpacity(.3),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 20.h,bottom: 70.h),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyles.font14Secondary700Weight,
                  ),
                  Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      /// 🔸 Main Button Body
                      Container(
                        height: 36,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.buttonYellow,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'اضف اسم الفريق',
                          style: TextStyles.font14Secondary700Weight,
                        ),
                      ),

                      /// Right Border
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: AppColors.buttonBorderOrange,
                        ),
                      ),

                      /// Bottom Border
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
