import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/packages/presentation/data/models/package.dart';

class PackageCard extends StatelessWidget {
  final Package? package;
  final String? title;
  final bool isLocked;
  final bool isSubscriptionLocked;
  final VoidCallback? onPressed;

  const PackageCard({
    super.key,
    this.package,
    this.title,
    this.isLocked = false,
    this.isSubscriptionLocked = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 145.w,
          height: 260.h, // تقليل الارتفاع قليلاً بسبب تصغير الصورة
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
                  title ?? package?.name ?? 'غير محدد',
                  style: TextStyles.font14Secondary700Weight,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Package Image
              SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: package != null
                      ? CachedNetworkImage(
                          imageUrl: package!.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            AppImages.ball,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            AppImages.ball,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          AppImages.ball,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              // Description
              if (package != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    package!.description,
                    style: TextStyles.font10Secondary700Weight,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    'وصف الباقة',
                    style: TextStyles.font10Secondary700Weight,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Price
              if (package != null) ...[
                Text(
                  '${package!.price} ريال',
                  style: TextStyles.font14Secondary700Weight.copyWith(
                    color: AppColors.buttonYellow,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ] else ...[
                Text(
                  'السعر',
                  style: TextStyles.font14Secondary700Weight.copyWith(
                    color: AppColors.buttonYellow,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],

              // Button
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: GestureDetector(
                  onTap: onPressed,
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
                          'اشتري الان',
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
              ),
            ],
          ),
        ),

        // Subscription lock overlay (clickable overlay with lock icon)
        if (isSubscriptionLocked) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: onPressed, // Make the entire overlay clickable
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Image.asset(
                    AppImages.lock,
                    width: 64,
                    height: 64,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
