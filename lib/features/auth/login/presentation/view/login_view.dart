import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/extension.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/login_otp_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';

class LoginView extends StatefulWidget {
  final String phone;
  final String otp;

  const LoginView({
    super.key,
    required this.phone,
    required this.otp,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();
    // Auto login when the view is created
    _performLogin();
  }

  void _performLogin() {
    context.read<LoginOtpCubit>().loginWithPhoneOtp(
      phone: widget.phone,
      otp: widget.otp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<LoginOtpCubit, LoginOtpState>(
          listener: (context, state) {
            if (state is LoginOtpSuccess) {
              // Save user data, token, and subscription
              GlobalStorage.saveUserData(state.response.data.user);
              GlobalStorage.saveToken(state.response.data.token);
              GlobalStorage.saveSubscription(state.response.data.user.subscription);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response.message),
                  backgroundColor: AppColors.green,
                ),
              );

              // Navigate to appropriate screen based on subscription
              _navigateAfterLogin();
            } else if (state is LoginOtpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
              // Go back to OTP screen on error
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                // Background gradient
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

                // Main content
                Center(
                  child: Container(
                    width: 740.w,
                    height: 250.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
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
                            'تسجيل الدخول',
                            style: TextStyles.font14Secondary700Weight,
                          ),
                        ),

                        /// Close button (top right of main container)
                        Positioned(
                          top: -15,
                          right: -15,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: SvgPicture.asset(AppIcons.cancel),
                          ),
                        ),

                        // Login content
                        Positioned(
                          top: 18.h,
                          left: 20.w,
                          right: 20.w,
                          bottom: 20.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Loading indicator
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                              ),

                              SizedBox(height: 20.h),

                              // Loading text
                              Text(
                                'جاري تسجيل الدخول...',
                                style: TextStyles.font14Secondary700Weight.copyWith(
                                  color: AppColors.secondaryColor,
                                ),
                              ),

                              SizedBox(height: 10.h),

                              Text(
                                'يرجى الانتظار',
                                style: TextStyles.font10Secondary700Weight.copyWith(
                                  color: AppColors.secondaryColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }

  void _navigateAfterLogin() async {
    // Wait a bit for the storage to be updated
    await Future.delayed(const Duration(milliseconds: 500));

    // Reload data from storage
    await GlobalStorage.loadData();

    // Check subscription status and navigate accordingly
    if (GlobalStorage.subscription != null) {
      if (GlobalStorage.subscription!.status == 'active') {
        print('🎯 Navigation after login: TeamCategoriesView (اشتراك نشط)');
        context.pushReplacementNamed(
          Routes.teamCategories,
          argument: {'limit': GlobalStorage.subscription!.limit ?? 4},
        );
      } else {
        print('🎯 Navigation after login: Packages (اشتراك غير نشط)');
        context.pushReplacementNamed(Routes.packages);
      }
    } else {
      print('🎯 Navigation after login: Packages (لا يوجد اشتراك)');
      context.pushReplacementNamed(Routes.packages);
    }
  }
}
