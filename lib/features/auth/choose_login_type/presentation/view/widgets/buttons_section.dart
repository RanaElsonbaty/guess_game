import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/helper_functions/extension.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/app_button.dart';

class ChooseLoginTypeButtonsSection extends StatelessWidget {
  final BoxConstraints constraints;

  const ChooseLoginTypeButtonsSection({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          text: 'تسجيل دخول برقم الهاتف',
          onPressed: () {
            context.pushReplacementNamed(Routes.otp);
          },
        ),
        SizedBox(height: 2.h),
        AppButton(
          text: 'تسجيل دخول بالبريد الإلكتروني',
          onPressed: () {
            context.pushReplacementNamed(Routes.emailLogin);
          },
        ),
        SizedBox(height: 20.h),
        // Don't have account section
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
              onTap: () => context.pushReplacementNamed(Routes.register),
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
      ],
    );
  }
}