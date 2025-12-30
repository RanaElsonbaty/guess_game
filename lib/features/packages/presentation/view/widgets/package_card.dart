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
          width: 160.w,
          height: 270.h, // تقليل الارتفاع قليلاً بسبب تصغير الصورة
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
                  title ?? package?.name ?? '',
                  style: TextStyles.font14Secondary700Weight,
                  textAlign: TextAlign.center,
                ),
              ),

              // Package Image
              SizedBox(
                width: 38.w,
                height: 38.h,
                child: package != null
                    ? CachedNetworkImage(
                        imageUrl: package!.image,
                        width: 38.w,
                        height: 38.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          AppImages.ball,
                          width: 38.w,
                          height: 38.h,
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          AppImages.ball,
                          width: 38.w,
                          height: 38.h,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        AppImages.ball,
                  width: 38.w,
                  height: 38.h,
                        fit: BoxFit.cover,
                      ),
              ),

              // Description
              if (package != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    package!.description,
                    style: TextStyles.font14Secondary700Weight,
                    textAlign: TextAlign.start,
                  ),
                ),
              ] else ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    '',
                    style: TextStyles.font10Secondary700Weight,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Price
              if (package != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.dollar,height: 20.h,width: 20.w,),
                    SizedBox(width: 4.w,),
                    Text(
                      '${package!.price} د.ك',
                      style: TextStyles.font15Green700Weight,
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  '',
                  style: TextStyles.font15Green700Weight,
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
