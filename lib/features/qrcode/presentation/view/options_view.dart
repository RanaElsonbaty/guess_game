import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/logout_cubit.dart';
import 'package:guess_game/core/widgets/subscription_alert_dialog.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_drawer_icon.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/yellow_pill_button.dart';

class OptionsView extends StatelessWidget {
  const OptionsView({super.key});

  Map<String, dynamic> _routeArgs(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return const {};
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = _routeArgs(context);
    final int gameId = args['gameId'] as int? ?? 0;
    final int team1Id = args['team1Id'] as int? ?? 0;
    final int team2Id = args['team2Id'] as int? ?? 0;
    // Keep names in global storage (prefill GroupsView).
    final String team1Name = args['team1Name'] as String? ?? GlobalStorage.team1Name;
    final String team2Name = args['team2Name'] as String? ?? GlobalStorage.team2Name;
    GlobalStorage.team1Name = team1Name;
    GlobalStorage.team2Name = team2Name;

    return BlocConsumer<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.response.message)),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.intro,
            (route) => false,
          );
        } else if (state is LogoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is LogoutLoading;
        return Scaffold(
      backgroundColor: Colors.white,
      drawer: const Drawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content container, positioned like QrcodeView.
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: 75.h, bottom: 28.h, left:0, right: 24.w),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: (255 * 2 + 92).w,
                    height: 280.h,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Background gradient (same style as winner views)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0XFF8e8e8e),
                                  AppColors.black.withOpacity(.2),
                                  Colors.white.withOpacity(.5),
                                ],
                              ),
                            ),
                          ),

                          // Header (painted) + title
                          Positioned(
                            top: -23,
                            left: 0,
                            child: SizedBox(
                              width: 285.w,
                              height: 80.h,
                              child: CustomPaint(painter: HeaderShapePainter()),
                            ),
                          ),
                          Positioned(
                            top: -13,
                            left: 50,
                            child: Text(
                              '؟',
                              style: TextStyles.font14Secondary700Weight,
                            ),
                          ),

                          // Close button
                          Positioned(
                            top: -15,
                            right: -15,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: SvgPicture.asset(AppIcons.cancel),
                            ),
                          ),

                          // Inner gray content area
                          Positioned(
                            top: 18.h,
                            left: 10.w,
                            right: 10.w,
                            bottom: 20.h,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0XFF231F20).withOpacity(.3),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 20.h),
                                    YellowPillButton(
                                      width: 220.w,
                                      height: 30.h,
                                      onTap: () => _comingSoon(context),
                                      child: Text(
                                        'باقه جديدة',
                                        style: TextStyles.font20Secondary700Weight,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    YellowPillButton(
                                      width: 220.w,
                                      height: 30.h,
                                      onTap: GlobalStorage.subscription?.limit != null && GlobalStorage.subscription!.limit! >= 1
                                        ? () async {
                                            // Start "add one category" flow: clear categories but keep team names.
                                            await GlobalStorage.saveGameData(
                                              team1Cats: [],
                                              team2Cats: [],
                                              t1Name: team1Name,
                                              t2Name: team2Name,
                                            );
                                            Navigator.of(context).pushNamed(
                                              Routes.teamCategories,
                                              arguments: {
                                                'limit': GlobalStorage.subscription?.limit ?? 1,
                                                'isAddOneCategory': true,
                                                'gameId': gameId,
                                                'team1Id': team1Id,
                                                'team2Id': team2Id,
                                              },
                                            );
                                          }
                                        : null,
                                      child: Text(
                                        'فئه +1 جديده',
                                        style: TextStyles.font20Secondary700Weight,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    YellowPillButton(
                                      width: 220.w,
                                      height: 30.h,
                                      onTap: () => _comingSoon(context),
                                      child: Text(
                                        'باقه جديدة نفس الجيم',
                                        style: TextStyles.font20Secondary700Weight,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 14.h),
                                    YellowPillButton(
                                      width: 100,
                                      height: 34,
                                      onTap: isLoading
                                          ? null
                                          : () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (dialogContext) {
                                                  return SubscriptionAlertDialog(
                                                    title: 'تسجيل الخروج',
                                                    content: 'هل أنت متأكد من تسجيل الخروج؟',
                                                    buttonText: 'تأكيد',
                                                    secondaryButtonText: 'إلغاء',
                                                    onSecondaryButtonPressed: () => Navigator.of(dialogContext).pop(),
                                                    onButtonPressed: () {
                                                      Navigator.of(dialogContext).pop();
                                                      context.read<LogoutCubit>().logout();
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                      child: Text(
                                        'خروج',
                                        style: TextStyles.font20Secondary700Weight,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Drawer icon (top left)
            Positioned(
              top: 6.h,
              left: 6.w,
              child: GameDrawerIcon(),
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}


