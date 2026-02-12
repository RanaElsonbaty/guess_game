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
            width: 150.w,
            height: 140.h,
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
              children: [
                // Title - في الأعلى
                Container(
                  height: 20.h,
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
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Image - تملأ باقي المساحة تحت العنوان مباشرة
                Expanded(
                  child: Stack(
                    children: [
                      // الصورة تأخذ كامل العرض والطول المتاح
                      Positioned.fill(
                        child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover, // تملأ المساحة كاملة زي صورة الكرة
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to static image if network image fails
                                return Image.asset(
                                  AppImages.ball,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              },
                            )
                          : Image.asset(
                              AppImages.ball,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                      ),

                      // Lock overlay if locked
                      if (isLocked) ...[
                        // Blur effect
                        Positioned.fill(
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

                        // Lock image - في المنتصف
                        Center(
                          child: Image.asset(
                            AppImages.lock,
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                      ],
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