import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/subscription_alert_dialog.dart';
import 'package:guess_game/features/levels/presentation/cubit/categories_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/category_card.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:shimmer/shimmer.dart';

class LevelsView extends StatefulWidget {
  const LevelsView({super.key});

  @override
  State<LevelsView> createState() => _LevelsViewState();
}

class _LevelsViewState extends State<LevelsView> {

  void _showSubscriptionDialog() {
    print('🔒 LevelsView: Showing subscription dialog (subscription is null)');
    final notificationCubit = context.read<NotificationCubit>();
    showDialog(
      context: context,
      barrierDismissible: false, // لا يغلق إلا بأيقونة الإلغاء
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: notificationCubit,
          child: const SubscriptionAlertDialog(),
        );
      },
    );
  }

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
                    width: 285.w,
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
                    'الفئات',
                    style: TextStyles.font14Secondary700Weight,
                  ),
                ),
                /// Close button (top right of main container)
                Positioned(
                  top: -15,
                  right: -15,
                  child: SvgPicture.asset(AppIcons.cancel),
                ),
                /// Categories container
                Positioned(
                  top: 18.h,
                  left: 10.w,
                  right: 10.w,
                  bottom: 20.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0XFF231F20).withOpacity(.3),
                    ),
                    child: BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, state) {
                        if (state is CategoriesError) {
                          return Center(
                            child: Text(
                              'خطأ في تحميل الفئات: ${state.message}',
                              style: TextStyles.font14Secondary700Weight.copyWith(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          // Show shimmer or real categories
                          final isLoading = state is CategoriesLoading;
                          final categories = state is CategoriesLoaded ? state.categories : [];

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
                                      vertical: 20.h,
                                    ),
                                    child: const CategoryCard(
                                      title: 'تحميل...',
                                      isLocked: false,
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            final isSubscriptionLocked = GlobalStorage.subscription == null; // إذا كان الاشتراك null، الكروت تكون مقفلة
                            print('🔒 LevelsView: isSubscriptionLocked = $isSubscriptionLocked (subscription: ${GlobalStorage.subscription})');
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 20.h,
                                  ),
                                  child: CategoryCard(
                                    title: category.name,
                                    isLocked: !category.status,
                                    isSubscriptionLocked: isSubscriptionLocked,
                                    onPressed: isSubscriptionLocked
                                        ? _showSubscriptionDialog
                                        : () {
                                            // Handle category selection - navigate to team categories
                                            final subscription = GlobalStorage.subscription;
                                            if (subscription != null) {
                                              final remaining = (subscription.limit ?? 0) - (subscription.used ?? 0);
                                              if (subscription.status == 'active' && remaining > 0) {
                                                // Active subscription with remaining questions - go to team categories
                                                Navigator.of(context).pushNamed(
                                                  Routes.teamCategories,
                                                  arguments: {'limit': subscription.limit ?? 4},
                                                );
                                              } else {
                                                // Show subscription dialog if subscription is not active or no questions left
                                                _showSubscriptionDialog();
                                              }
                                            } else {
                                              // Should not happen since isSubscriptionLocked is false, but fallback
                                              _showSubscriptionDialog();
                                            }
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
