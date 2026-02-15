import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String? imageUrl; // Dynamic image from API
  final bool isLocked;
  final bool isSubscriptionLocked;
  final VoidCallback? onPressed;
  final bool showButton; // إضافة parameter لإظهار/إخفاء الزر

  const CategoryCard({
    super.key,
    required this.title,
    this.imageUrl, // Optional parameter for dynamic image
    this.isLocked = false,
    this.isSubscriptionLocked = false,
    this.onPressed,
    this.showButton = true, // افتراضياً يظهر الزر
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowLock = isLocked || isSubscriptionLocked;
    if (shouldShowLock) {
      print('🔒 CategoryCard: Showing lock for "$title" (isLocked: $isLocked, isSubscriptionLocked: $isSubscriptionLocked)');
    }
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          Container(
            width: 150.w,
            height: 85.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF79899f), Color(0xFF8b929b), Color(0xFF79899f)],
              ),
            ),
            child: Stack(
              children: [
                // الصورة تبدأ من أسفل العنوان
                Positioned(
                  top: 20.h, // تبدأ من أسفل العنوان
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            AppImages.ball,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        AppImages.ball,
                        fit: BoxFit.cover,
                      ),
                ),

                // Lock overlay if locked
                if (isLocked || isSubscriptionLocked) ...[
                  // Blur effect
                  Positioned(
                    top: 20.h, // يبدأ من أسفل العنوان
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Lock image في المنتصف
                  Positioned(
                    top: 20.h,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: Image.asset(
                        AppImages.lock,
                        width: 24.w,
                        height: 24.h,
                      ),
                    ),
                  ),
                ],

                // Title في الأعلى
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 20.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppImages.card),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Text(
                      title,
                      style: TextStyles.font14Secondary700Weight,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Button في الأسفل - يظهر فقط إذا كان showButton = true
                if (showButton)
                  Positioned(
                    bottom: 4.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          /// 🔸 Main Button Body
                          Container(
                            height: 20.h,
                            width: 65.w,
                            decoration: BoxDecoration(
                              color: AppColors.buttonYellow,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'اختر',
                              style: TextStyles.font10Secondary700Weight.copyWith(fontSize: 9.sp),
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
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}