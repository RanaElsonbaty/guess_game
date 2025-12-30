import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/extension.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/app_button.dart';
import 'package:guess_game/features/auth/register/presentation/cubit/register_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => RegisterCubit(getIt()),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Background gradient - Optimized for performance
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0XFF8e8e8e),
                      Color(0x33000000), // Optimized AppColors.black.withOpacity(.2)
                      Color(0x80FFFFFF), // Optimized Colors.white.withOpacity(.5)
                    ],
                  ),
                ),
                child: SizedBox.expand(),
              ),

              // Padding from top
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: BlocConsumer<RegisterCubit, RegisterState>(
                    listener: (context, state) {
                      if (state is RegisterSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.response.message),
                            backgroundColor: AppColors.green,
                          ),
                        );
                        // Navigate to intro page after successful registration
                        context.pushReplacementNamed(Routes.intro);
                      } else if (state is RegisterError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Container(
                            width: 740.w,
                            margin: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
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
                                      'إنشاء حساب',
                                      style: TextStyles.font14Secondary700Weight,
                                    ),
                                  ),

                                  /// Close button (top right of main container)
                                  Positioned(
                                    top: -15,
                                    right: -15,
                                    child: GestureDetector(
                                      onTap: () => context.pushReplacementNamed(Routes.intro),
                                      child: SvgPicture.asset(AppIcons.cancel),
                                    ),
                                  ),

                                  // Register form content
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
                                            'أدخل بياناتك لإنشاء حساب جديد',
                                            style: TextStyles.font10Secondary700Weight.copyWith(
                                              color: AppColors.secondaryColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          SizedBox(height: 30.h),

                                          // Name field
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
                                              controller: _nameController,
                                              style: TextStyles.font14Secondary700Weight.copyWith(
                                                color: AppColors.secondaryColor,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'الاسم',
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
                                                  Icons.person,
                                                  color: AppColors.secondaryColor,
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 12.h,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'يرجى إدخال الاسم';
                                                }
                                                if (value.length < 2) {
                                                  return 'الاسم يجب أن يكون حرفين على الأقل';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),

                                          SizedBox(height: 15.h),

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

                                          // Phone field
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
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              style: TextStyles.font14Secondary700Weight.copyWith(
                                                color: AppColors.secondaryColor,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'رقم الهاتف',
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
                                                  Icons.phone,
                                                  color: AppColors.secondaryColor,
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 12.h,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'يرجى إدخال رقم الهاتف';
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

                                          SizedBox(height: 15.h),

                                          // Confirm Password field
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
                                              controller: _confirmPasswordController,
                                              obscureText: true,
                                              style: TextStyles.font14Secondary700Weight.copyWith(
                                                color: AppColors.secondaryColor,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'تأكيد كلمة المرور',
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
                                                  Icons.lock_outline,
                                                  color: AppColors.secondaryColor,
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 12.h,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'يرجى تأكيد كلمة المرور';
                                                }
                                                if (value != _passwordController.text) {
                                                  return 'كلمة المرور غير متطابقة';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),

                                          SizedBox(height: 25.h),

                                          // Register button
                                          AppButton(
                                            text: '',
                                            onPressed: state is RegisterLoading
                                                ? null
                                                : () {
                                                    if (_formKey.currentState!.validate()) {
                                                      context.read<RegisterCubit>().register(
                                                        name: _nameController.text.trim(),
                                                        email: _emailController.text.trim(),
                                                        phone: _phoneController.text.trim(),
                                                        password: _passwordController.text,
                                                        passwordConfirmation: _confirmPasswordController.text,
                                                      );
                                                    }
                                                  },
                                            child: state is RegisterLoading
                                                ? SizedBox(
                                                    width: 24.w,
                                                    height: 24.h,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                                                    ),
                                                  )
                                                : Text(
                                                    'إنشاء حساب',
                                                    style: TextStyles.font30Secondary700Weight,
                                                  ),
                                          ),

                                          SizedBox(height: 15.h),

                                          // Back to intro
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'لديك حساب بالفعل؟ ',
                                                style: TextStyles.font10Secondary700Weight.copyWith(
                                                  color: AppColors.secondaryColor.withOpacity(0.7),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => context.pushReplacementNamed(Routes.chooseLoginType),
                                                child: Text(
                                                  'تسجيل الدخول',
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
             ] )
          ),
    )
    );
  }
}