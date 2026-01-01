import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';

class GreenPillButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double? width;
  final double? height;
  final double? borderRadius;

  const GreenPillButton({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final double hPx = (height ?? 34).h;
    // Fixed rounding as requested.
    final double r = borderRadius ?? 15.sp;
    final double rDark = r;
    final double rInnerBottom = r;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: hPx,
        width: (width ?? 104).w,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            /// Soft drop shadow under the 3D base
            Positioned(
              bottom: 0,
              left: 6.w,
              right: 6.w,
              child: Container(
                height: 10.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(rDark)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),

            /// Bottom gradient shadow (tight, like the reference)
            Positioned(
              bottom: 0,
              left: 8.w,
              right: 8.w,
              child: Container(
                height: 8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(rDark)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.greenButtonDark.withOpacity(0.85),
                      AppColors.greenButtonDark,
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),

            /// External bottom border
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 7.h,
                decoration: BoxDecoration(
                  color: AppColors.greenButtonDark,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(rDark)),
                ),
              ),
            ),

            /// Inner bottom border
            Positioned(
              bottom: 2.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.greenButtonLight.withOpacity(0.7),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(rInnerBottom)),
                ),
              ),
            ),

            /// Main pill body
            Container(
              height: hPx - 2.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.greenButtonLight,
                    Color(0xFF12D900),
                  ],
                ),
                borderRadius: BorderRadius.circular(r),
                // No border by design; the 3D effect comes from the bottom layers only.
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greenButtonDark.withOpacity(0.95),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: child,
            ),

            /// Subtle top highlight to match the glossy feel
            Positioned(
              top: 2.h,
              left: 10.w,
              right: 10.w,
              child: Container(
                height: 7.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


