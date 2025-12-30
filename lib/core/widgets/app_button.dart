import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? child;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        height: 58.h,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            /// 🌫️ Bottom Gradient Shadow
            Positioned(
              bottom: 0,
              left: 10.w,
              right: 10.w,
              child: Container(
                height: 10.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20.r),
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gradiant1,
                      AppColors.gradiant2,
                      AppColors.gradiant3,
                      AppColors.gradiant4,
                      AppColors.gradiant5
                    ],
                  ),
                ),
              ),
            ),

            /// 🔻 External Bottom Border
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: AppColors.buttonEternalBorder,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(18.r),
                  ),
                ),
              ),
            ),

            /// 🔻 Inner Bottom Border
            Positioned(
              bottom: 3.h,
              left: 6.w,
              right: 6.w,
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.buttonInnerBorder,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14.r),
                  ),
                ),
              ),
            ),

            /// 🔸 Main Button Body
            Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.buttonYellow,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonEternalBorder,
                    offset: const Offset(0, 5),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: child ?? Text(
                text,
                style: TextStyles.font30Secondary700Weight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
