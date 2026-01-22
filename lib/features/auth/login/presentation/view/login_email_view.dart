import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/extension.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/app_button.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/login_email_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';

class LoginEmailView extends StatefulWidget {
  const LoginEmailView({super.key});

  @override
  State<LoginEmailView> createState() => _LoginEmailViewState();
}

class _LoginEmailViewState extends State<LoginEmailView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => LoginEmailCubit(getIt()),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
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

              // Padding from top
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: BlocConsumer<LoginEmailCubit, LoginEmailState>(
                  listener: (context, state) {
                    if (state is LoginEmailSuccess) {
                      // Save user data, token, and subscription
                      GlobalStorage.saveUserData(state.response.data.user);
                      GlobalStorage.saveToken(state.response.data.token);
                      GlobalStorage.saveSubscription(state.response.data.user.subscription);

                      print('✅ API Response: ${state.response.message}');

                      // Navigate based on subscription status
                      _navigateAfterLogin();
                    } else if (state is LoginEmailError) {
                      print('❌ API Error: ${state.message}');
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      child: Center(
                        child: Container(
                          width: 740.w,
                          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                                  onTap: () => context.pushReplacementNamed(Routes.chooseLoginType),
                                  child: SvgPicture.asset(AppIcons.cancel),
                                ),
                              ),

                              // Login form content
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.w, 38.h, 20.w, 20.h),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20.h),

                                      // Subtitle
                                      Text(
                                        'أدخل بياناتك لتسجيل الدخول',
                                        style: TextStyles.font10Secondary700Weight.copyWith(
                                          color: AppColors.secondaryColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      SizedBox(height: 30.h),

                                      // Email field
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          style: TextStyles.font14Secondary700Weight.copyWith(
                                            color: AppColors.secondaryColor,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'البريد الإلكتروني',
                                            labelStyle: TextStyles.font10Secondary700Weight.copyWith(
                                              color: AppColors.secondaryColor.withOpacity(0.7),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            prefixIcon: Icon(
                                              Icons.email,
                                              color: AppColors.secondaryColor,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 12.h,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'يرجى إدخال البريد الإلكتروني';
                                            }
                                            if (!value.contains('@')) {
                                              return 'يرجى إدخال بريد إلكتروني صحيح';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),

                                      SizedBox(height: 15.h),

                                      // Password field
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: TextStyles.font14Secondary700Weight.copyWith(
                                            color: AppColors.secondaryColor,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'كلمة المرور',
                                            labelStyle: TextStyles.font10Secondary700Weight.copyWith(
                                              color: AppColors.secondaryColor.withOpacity(0.7),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: AppColors.secondaryColor,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 12.h,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'يرجى إدخال كلمة المرور';
                                            }
                                            if (value.length < 6) {
                                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),

                                      SizedBox(height: 25.h),

                                      // Login button
                                      AppButton(
                                        text: '',
                                        onPressed: state is LoginEmailLoading
                                            ? null
                                            : () {
                                                if (_formKey.currentState!.validate()) {
                                                  context.read<LoginEmailCubit>().loginWithEmail(
                                                    email: _emailController.text.trim(),
                                                    password: _passwordController.text,
                                                  );
                                                }
                                              },
                                        child: state is LoginEmailLoading
                                            ? SizedBox(
                                                width: 24.w,
                                                height: 24.h,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                                                ),
                                              )
                                            : Text(
                                                'تسجيل الدخول',
                                                style: TextStyles.font30Secondary700Weight,
                                              ),
                                      ),

                                      SizedBox(height: 15.h),

                                      // Create account link
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ليس لديك حساب؟ ',
                                            style: TextStyles.font10Secondary700Weight.copyWith(
                                              color: AppColors.secondaryColor.withOpacity(0.7),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              context.pushReplacementNamed(Routes.register);
                                            },
                                            child: Text(
                                              'إنشاء حساب',
                                              style: TextStyles.font10Secondary700Weight.copyWith(
                                                color: AppColors.secondaryColor,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10.h),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateAfterLogin() async {
    // Wait a bit for the storage to be updated
    await Future.delayed(const Duration(milliseconds: 500));

    // Reload data from storage
    await GlobalStorage.loadData();

    // Always navigate to LevelsView after successful login
    print('🎯 Navigation after login: LevelsView (دائماً بعد تسجيل الدخول بنجاح)');
    context.pushReplacementNamed(Routes.level);
  }
}