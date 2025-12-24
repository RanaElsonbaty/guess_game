import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/packages/presentation/cubit/packages_cubit.dart';
import 'package:guess_game/features/packages/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/packages/presentation/view/widgets/package_card.dart';
import 'package:shimmer/shimmer.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            width: 740.w,
            height: 240.h,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /// Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0XFF8e8e8e),
                        AppColors.black.withOpacity(.2),
                        Colors.white.withOpacity(.5),
                      ],
                    ),
                  ),
                ),
                /// Header (painted) INSIDE main container
                Positioned(
                  top: -23,
                  left: 0,
                  child: SizedBox(
                    width: 260.w,
                    height: 80.h,
                    child: CustomPaint(
                      painter: HeaderShapePainter(),
                    ),
                  ),
                ),
                Positioned(
                  top: -13,
                  left: 25,
                  child: Text(
                    'الباقات',
                    style: TextStyles.font14Secondary700Weight,
                  ),
                ),
                /// Close button (top right of main container)
                Positioned(
                  top: -15,
                  right: -15,
                  child: SvgPicture.asset(AppIcons.cancel),
                ),
                /// Packages container
                Positioned(
                  top: 18.h,
                  left: 10.w,
                  right: 10.w,
                  bottom: 20.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0XFF231F20).withOpacity(.3),
                    ),
                    child: BlocBuilder<PackagesCubit, PackagesState>(
                      builder: (context, state) {
                        if (state is PackagesError) {
                          return Center(
                            child: Text(
                              'خطأ في تحميل الباقات: ${state.message}',
                              style: TextStyles.font14Secondary700Weight.copyWith(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          // Show shimmer or real packages
                          final isLoading = state is PackagesLoading;
                          final packages = state is PackagesLoaded ? state.packages : [];

                          if (isLoading) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 10.h, // تقليل الـ padding العمودي
                                    ),
                                    child: const PackageCard(
                                      title: 'تحميل...',
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              itemCount: packages.length,
                              itemBuilder: (context, index) {
                                final package = packages[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 10.h, // تقليل الـ padding العمودي بسبب زيادة ارتفاع الكارت
                                  ),
                                  child: PackageCard(
                                    package: package,
                                    onPressed: () {
                                      // TODO: Handle package selection
                                      print('شراء الباقة: ${package.name}');
                                    },
                                  ),
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

}
