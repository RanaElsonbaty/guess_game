import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/features/about/presentation/cubit/about_cubit.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
      create: (context) => AboutCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('حول التطبيق'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),

                  // App Logo/Icon
                  Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60.r),
                    ),
                    child: Icon(
                      Icons.games,
                      size: 60.sp,
                      color: AppColors.secondaryColor,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // App Name
                  Text(
                    'Guess Game',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Version
                  Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Description
                  Text(
                    'تطبيق ألعاب التخمين الممتع\nاستمتع بألعاب متنوعة ومثيرة\nمع أصدقائك وعائلتك!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 60.h),

                  // Developer Info
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: AppColors.secondaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'تم التطوير بواسطة',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'فريق التطوير',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // Action Button
                  ElevatedButton(
                    onPressed: () {
                      context.read<AboutCubit>().toggleInfo();
                    },
                    child: Text(state.showExtraInfo ? 'إخفاء المعلومات الإضافية' : 'عرض المعلومات الإضافية'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Extra Info (shown when button is pressed)
                  if (state.showExtraInfo) ...[
                    Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'معلومات إضافية:\n• تطبيق تعليمي وترفيهي\n• يدعم اللغة العربية\n• متوافق مع جميع الأجهزة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.4,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        ),
      ),
    ),
    );
  }
}
