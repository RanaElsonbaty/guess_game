import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final bool isLocked;
  final bool isSubscriptionLocked;
  final VoidCallback? onPressed;

  const CategoryCard({
    super.key,
    required this.title,
    this.isLocked = false,
    this.isSubscriptionLocked = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          Container(
            width: 145.w,
            height: 200.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF79899f), Color(0xFF8b929b), Color(0xFF79899f)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Container(
                  height: 40,
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

                // Ball Image with optional lock overlay
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ball Image
                      Image.asset(
                        AppImages.ball,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),

                      // Lock overlay if locked
                      if (isLocked) ...[
                        // Blur effect
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(36),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Lock image
                        Image.asset(
                          AppImages.lock,
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ],
                  ),
                ),

                // Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// 🔸 Main Button Body
                      Container(
                        height: 36,
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.buttonYellow,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'اختر',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}