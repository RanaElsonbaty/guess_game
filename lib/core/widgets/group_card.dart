import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/file_shape_clipper.dart';

class GroupCard extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String hintText;

  const GroupCard({
    super.key,
    required this.title,
    this.controller,
    this.onChanged,
    this.hintText = 'اسم الفريق',
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FileClipper(),
      child: Container(
        width: 237.w,
        height: 210.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0XFF8e8e8e),
              AppColors.black.withOpacity(.3),
              Colors.white.withOpacity(.5),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10.w,right:10.w,top: 35.h),

          /// 👇 inner clipped container
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0XFF231F20).withOpacity(.3),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 20.h,bottom: 70.h),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyles.font14Secondary700Weight,
                  ),
                  Spacer(),
                  Container(
                    width: 160.w, // تكبير العرض
                    padding: EdgeInsets.symmetric(horizontal: 12.w,vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.buttonYellow,
                      border: Border(
                        right: BorderSide(
                          color: AppColors.buttonBorderOrange,
                          width: 2,
                        ),
                        bottom: BorderSide(
                          color: AppColors.buttonBorderOrange,
                          width: 2,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      style: TextStyles.font13Secondary700Weight,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyles.font14Secondary700Weight,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
