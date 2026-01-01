import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/features/auth/choose_login_type/presentation/view/widgets/buttons_section.dart';
import 'package:guess_game/features/Intro/presentation/view/widgets/logo_section.dart';

class ChooseLoginTypeView extends StatefulWidget {
  const ChooseLoginTypeView({super.key});

  @override
  State<ChooseLoginTypeView> createState() => _ChooseLoginTypeViewState();
}

class _ChooseLoginTypeViewState extends State<ChooseLoginTypeView> {
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
                    padding: EdgeInsets.symmetric(horizontal: 120.w),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          LogoSection(constraints: constraints),
                          SizedBox(height: constraints.maxHeight * 0.04),
                          // Buttons
                          ChooseLoginTypeButtonsSection(constraints: constraints),
                        ],
                      ),
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



