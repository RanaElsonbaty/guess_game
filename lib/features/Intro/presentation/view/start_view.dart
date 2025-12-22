import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guess_game/core/helper_functions/extension.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/fonts.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/app_button.dart';
import 'package:guess_game/features/Intro/presentation/view/widgets/logo_section.dart';

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FadeIn(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 240.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        LogoSection(constraints: constraints),
                        Text('khamny',style: GoogleFonts.getFont(
                          AppFonts.aclonica,
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 48.sp,
                        ),),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        // Button
                        AppButton(text: 'ابدأ اللعبه', onPressed: () {
                          context.pushReplacementNamed(Routes.level);
                        },),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

