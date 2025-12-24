import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';

class SubscriptionAlertDialog extends StatelessWidget {
  const SubscriptionAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // خلفية شفافة تماماً
      child: Container(
        width: 400.w,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF79899f).withOpacity(0.3), // خفيف جداً
              Color(0xFF8b929b).withOpacity(0.3), // خفيف جداً
              Color(0xFF79899f).withOpacity(0.3), // خفيف جداً
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الشريط العلوي مع الأيقونة وكلمة اشعار
            Container(
              width: double.infinity,
              height: 60.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.card),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // أيقونة الإلغاء على اليمين
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      AppIcons.cancel,
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                  // كلمة "اشعار" في الوسط
                  Text(
                    'اشعار',
                    style: TextStyles.font24Secondary700Weight,
                    textAlign: TextAlign.center,
                  ),
                  // مساحة فارغة على اليسار
                  SizedBox(width: 40.w),

                ],
              ),
            ),

            // المحتوى الشفاف
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: const BoxDecoration(
                color: Colors.transparent, // شفاف تماماً
              ),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // النص الرئيسي
                  Text(
                    'يجب اختيار احد الباقات لدينا لكي يتم البدء اللعبه\nالان بكل سهوله',
                    style: TextStyles.font16Secondary700Weight,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 30.h),

                  // الزر الأخضر "شراء الان"
                  GestureDetector(
                    onTap: () {
                      // إغلاق الحوار أولاً
                      Navigator.of(context).pop();
                      // ثم الانتقال إلى صفحة الباقات عبر routes
                      Navigator.of(context).pushNamed(Routes.packages);
                    },
                    child: SizedBox(
                      height: 40.h,
                      width: 104.w,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          /// 🌫️ Bottom Gradient Shadow
                          Positioned(
                            bottom: 0,
                            left: 8.w,
                            right: 8.w,
                            child: Container(
                              height: 8.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(15.r),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.greenButtonDark.withOpacity(0.8),
                                    AppColors.greenButtonDark,
                                    Colors.black,
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
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: AppColors.greenButtonDark,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(13.r),
                                ),
                              ),
                            ),
                          ),

                          /// 🔻 Inner Bottom Border
                          Positioned(
                            bottom: 2.h,
                            left: 4.w,
                            right: 4.w,
                            child: Container(
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: AppColors.greenButtonLight.withOpacity(0.7),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(10.r),
                                ),
                              ),
                            ),
                          ),

                          /// 🔸 Main Button Body
                          Container(
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: AppColors.greenButtonLight,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.greenButtonDark,
                                  offset: const Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'شراء الان',
                              style: TextStyles.font10Secondary700Weight.copyWith(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
