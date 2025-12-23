import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/fonts.dart';

class TextStyles {
  static final font30Secondary700Weight = GoogleFonts.getFont(
    AppFonts.bukra,
    color: AppColors.secondaryColor,
    fontWeight: FontWeight.w700,
    fontSize: 30.sp,
  );
  static final font48Secondary400Weight = GoogleFonts.getFont(
    AppFonts.bukra,
    color: AppColors.secondaryColor,
    fontWeight: FontWeight.w400,
    fontSize: 48.sp,
  );
  static final font14Secondary700Weight = GoogleFonts.getFont(
    AppFonts.bukra,
    color: AppColors.secondaryColor,
    fontWeight: FontWeight.w700,
    fontSize: 14.sp,
  );
  static final font10Secondary700Weight = GoogleFonts.getFont(
    AppFonts.bukra,
    color: AppColors.secondaryColor,
    fontWeight: FontWeight.w700,
    fontSize: 10.sp,
  );
}
