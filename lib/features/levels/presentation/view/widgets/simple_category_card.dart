import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';

class SimpleCategoryCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final bool isLocked;
  final bool isSelected;
  final VoidCallback? onTap;

  const SimpleCategoryCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.isLocked = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Stack(
        children: [
          Container(
            width: 150.w, // حجم أصغر من CategoryCard الأصلي (145.w)
            height: 140.h, // حجم أصغر من CategoryCard الأصلي (200.h)
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF79899f), Color(0xFF8b929b), Color(0xFF79899f)],
              ),
              // إضافة border للاختيار
              border: isSelected 
                  ? Border.all(color: AppColors.secondaryColor, width: 3)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title - نفس التصميم بس بحجم أصغر
                Container(
                  height: 20.h, // أصغر من 40
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
                    style: TextStyles.font14Secondary700Weight, // خط أصغر
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Ball Image with optional lock overlay - نفس التصميم بس بحجم أصغر
                SizedBox(
                  width: 45.w, // أصغر من 72
                  height: 45.h, // أصغر من 72
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dynamic Image from API or fallback to static ball image
                      imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to static image if network image fails
                              return Image.asset(
                                AppImages.ball,
                                width: 50.w,
                                height: 50.h,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            AppImages.ball,
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
                          ),

                      // Lock overlay if locked
                      if (isLocked) ...[
                        // Blur effect
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25.w), // نصف العرض
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.w),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Lock image - حجم أصغر
                        Image.asset(
                          AppImages.lock,
                          width: 18.w, // أصغر من 24
                          height: 18.h, // أصغر من 24
                        ),
                      ],
                    ],
                  ),
                ),

                // مساحة فارغة بدلاً من الزرار
                SizedBox(height: 8.h), // مساحة بدلاً من الزرار
              ],
            ),
          ),
        ],
      ),
    );
  }
}