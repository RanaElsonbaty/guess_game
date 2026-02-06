import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/helper_functions/extension.dart';
import 'package:guess_game/core/helper_functions/shared_preferences.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/app_button.dart';
import 'package:guess_game/core/helper_functions/toast_helper.dart';
import 'package:guess_game/features/auth/otp/presentation/cubit/otp_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';

class OtpVerifyView extends StatefulWidget {
  final String phone;

  const OtpVerifyView({
    super.key,
    required this.phone,
  });

  @override
  State<OtpVerifyView> createState() => _OtpVerifyViewState();
}

class _OtpVerifyViewState extends State<OtpVerifyView> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  Timer? _timer;
  int _remainingSeconds = 60; // دقيقة واحدة = 60 ثانية
  String _phoneNumber = ''; // حفظ رقم الهاتف محلياً

  @override
  void initState() {
    super.initState();
    _initializePhoneNumber();
    // Auto focus on last field (reverse direction)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[5].requestFocus();
    });
    // Start timer
    _startTimer();
  }

  void _initializePhoneNumber() {
    // محاولة استخدام رقم الهاتف من widget أولاً
    if (widget.phone.isNotEmpty) {
      _phoneNumber = widget.phone;
      // حفظ رقم الهاتف (غير متزامن)
      CacheHelper.saveOtpPhone(_phoneNumber).then((_) {
        print('📱 OtpVerifyView: تم حفظ رقم الهاتف من widget: "$_phoneNumber"');
      });
      print('📱 OtpVerifyView: رقم الهاتف من widget: "$_phoneNumber"');
    } else {
      // إذا كان فارغاً، جلب الرقم المحفوظ
      final savedPhone = CacheHelper.getOtpPhone();
      if (savedPhone != null && savedPhone.isNotEmpty) {
        _phoneNumber = savedPhone;
        print('📱 OtpVerifyView: رقم الهاتف من الذاكرة: "$_phoneNumber"');
        // تحديث الواجهة بعد تحميل الرقم
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        _phoneNumber = '';
        print('⚠️ OtpVerifyView: لم يتم العثور على رقم هاتف');
      }
    }
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to previous field (reverse direction)
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    } else {
      // Move to next field on backspace (reverse direction)
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    // Auto verify when all fields are filled
    _checkAutoVerify();
  }

  void _checkAutoVerify() {
    final otp = _getOtpString();
    if (otp.length == 6) {
      _verifyOtp(otp);
    }
  }

  String _getOtpString() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOtp(String otp) {
    context.read<OtpCubit>().verifyOtp(
      phone: _phoneNumber,
      otp: otp,
      takeType: 'login',
    );
  }

  Future<void> _resendOtp() async {
    // Ensure phone number is not empty
    if (_phoneNumber.isEmpty) {
      ToastHelper.showError(context, 'رقم الهاتف غير موجود');
      return;
    }
    
    print('🔄 إعادة إرسال الرمز للرقم: $_phoneNumber');
    // حفظ رقم الهاتف قبل الإرسال
    await CacheHelper.saveOtpPhone(_phoneNumber);
    context.read<OtpCubit>().generateOtp(
      phone: _phoneNumber,
      takeType: 'login',
    );
    // Restart timer after resending
    _startTimer();
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    // Update phone number if provided
                    if (state.phone.isNotEmpty) {
                      _phoneNumber = state.phone;
                      // حفظ رقم الهاتف بعد نجاح إعادة الإرسال
                      CacheHelper.saveOtpPhone(_phoneNumber);
                      print('📱 تم تحديث رقم الهاتف إلى: $_phoneNumber');
                      setState(() {}); // تحديث الواجهة
                    }
                    print('✅ API Response: ${state.response.message}');
                    // Restart timer after successful resend
                    _startTimer();
                  } else if (state is OtpVerifySuccess) {
                    print('✅ API Response: ${state.response.message}');
                    // Navigate to login view through routes
                    Navigator.of(context).pushReplacementNamed(
                      Routes.login,
                      arguments: {
                        'phone': _phoneNumber,
                        'otp': _getOtpString(),
                      },
                    );
                  } else if (state is OtpGenerateError) {
                    print('❌ API Error (Generate): ${state.message}');
                    // Show error in toast
                    ToastHelper.showError(context, state.message);
                  } else if (state is OtpVerifyError) {
                    print('❌ API Error (Verify): ${state.message}');
                    // Show error in toast
                    ToastHelper.showError(context, state.message);
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: 740.w,
                        height: 350.h,
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
                              left: 16,
                              child: Text(
                                'التحقق من الرمز',
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

                            // OTP content
                            Positioned(
                              top: 18.h,
                              left: 20.w,
                              right: 20.w,
                              bottom: 20.h,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 20.h),

                                  // Subtitle
                                  Text(
                                    'تم إرسال رمز التحقق إلى',
                                    style: TextStyles.font10Secondary700Weight.copyWith(
                                      color: AppColors.secondaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: 8.h),

                                  Text(
                                    _phoneNumber,
                                    style: TextStyles.font14Secondary700Weight.copyWith(
                                      color: AppColors.secondaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  SizedBox(height: 30.h),

                                  // OTP Input Fields
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      6,
                                      (index) => Container(
                                        width: 45.w,
                                        height: 55.h,
                                        margin: EdgeInsets.symmetric(horizontal: 4.w),
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
                                          controller: _otpControllers[index],
                                          focusNode: _focusNodes[index],
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          maxLength: 1,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          style: TextStyles.font16Secondary700Weight.copyWith(
                                            color: AppColors.secondaryColor,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            counterText: '',
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: 16.h,
                                            ),
                                          ),
                                          onChanged: (value) => _onOtpChanged(value, index),
                                          onTap: () {
                                            // Clear the field when tapped
                                            _otpControllers[index].clear();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 25.h),

                                  // Resend OTP section with timer
                                  BlocBuilder<OtpCubit, OtpState>(
                                    builder: (context, state) {
                                      if (_remainingSeconds > 0) {
                                        // Show timer
                                        return Column(
                                          children: [
                                            Text(
                                              'إعادة إرسال الرمز خلال',
                                              style: TextStyles.font10Secondary700Weight.copyWith(
                                                color: AppColors.secondaryColor.withOpacity(0.7),
                                                decorationColor: AppColors.secondaryColor
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              _formatTime(_remainingSeconds),
                                              style: TextStyles.font14Secondary700Weight.copyWith(
                                                color: AppColors.secondaryColor,
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        // Show clickable resend text
                                        return GestureDetector(
                                          onTap: state is OtpGenerateLoading ? null : _resendOtp,
                                          child: Text(
                                            'إعادة إرسال الكود',
                                            style: TextStyles.font10Secondary700Weight.copyWith(
                                              color: AppColors.secondaryColor,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),

                                  SizedBox(height: 20.h),

                                  // Verify button
                                  BlocBuilder<OtpCubit, OtpState>(
                                    builder: (context, state) {
                                      return AppButton(
                                        text: state is OtpVerifyLoading ? '' : 'تحقق من الرمز',
                                        onPressed: state is OtpVerifyLoading ? null : () {
                                          final otp = _getOtpString();
                                          if (otp.length == 6) {
                                            _verifyOtp(otp);
                                          }
                                        },
                                        child: state is OtpVerifyLoading
                                            ? SizedBox(
                                                width: 24.w,
                                                height: 24.h,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                                                ),
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                ],
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
    );
  }
}