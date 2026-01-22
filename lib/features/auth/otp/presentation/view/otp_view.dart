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
import 'package:guess_game/features/auth/otp/presentation/cubit/otp_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ OtpView: تم بناء الصفحة');
    return SafeArea(
      child: BlocProvider(
        create: (context) => OtpCubit(getIt()),
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
                child: BlocConsumer<OtpCubit, OtpState>(
                  listener: (context, state) {
                    if (state is OtpGenerateSuccess) {
                      print('✅ API Response: ${state.response.message}');
                      // الانتقال لصفحة التحقق من OTP
                      context.pushReplacementNamed(
                        Routes.otpVerify,
                        argument: state.phone,
                      );
                    } else if (state is OtpGenerateError) {
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
                                left: 12,
                                child: Text(
                                  'إرسال رمز التحقق',
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

                              // Phone input form content
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
                                        'أدخل رقم هاتفك لإرسال رمز التحقق',
                                        style: TextStyles.font10Secondary700Weight.copyWith(
                                          color: AppColors.secondaryColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      SizedBox(height: 30.h),

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

                                      SizedBox(height: 40.h),

                                      // Send OTP button
                                      AppButton(
                                        text: '',
                                        onPressed: state is OtpGenerateLoading
                                            ? null
                                            : () {
                                                print('🎯 تم الضغط على زر إرسال رمز التحقق');
                                                print('📱 رقم الهاتف: "${_phoneController.text.trim()}"');

                                                if (_formKey.currentState!.validate()) {
                                                  print('✅ تم التحقق من صحة النموذج');
                                                  context.read<OtpCubit>().generateOtp(
                                                    phone: _phoneController.text.trim(),
                                                    takeType: 'login',
                                                  );
                                                } else {
                                                  print('❌ فشل التحقق من صحة النموذج');
                                                }
                                              },
                                        child: state is OtpGenerateLoading
                                            ? SizedBox(
                                                width: 24.w,
                                                height: 24.h,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                                                ),
                                              )
                                            : Text(
                                                'إرسال رمز التحقق',
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


}