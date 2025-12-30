import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/helper_functions/extension.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/widgets/app_button.dart';

class ButtonsSection extends StatelessWidget {
  final BoxConstraints constraints;

  const ButtonsSection({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          text: 'تسجيل دخول',
          onPressed: () {
            context.pushReplacementNamed(Routes.chooseLoginType);
          },
        ),
        SizedBox(height: 2.h),
        AppButton(
          text: 'إنشاء حساب',
          onPressed: () {
            context.pushReplacementNamed(Routes.register);
          },
        ),
      ],
    );
  }
  }