import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guess_game/core/helper_functions/extension.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/fonts.dart';
import 'package:guess_game/core/widgets/app_button.dart';
import 'package:guess_game/features/Intro/presentation/view/widgets/logo_section.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/auth_cubit.dart';
import 'package:guess_game/core/injection/service_locator.dart';

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
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 240.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        // Logo
                        LogoSection(constraints: constraints),
                        Text('khamni',style: GoogleFonts.getFont(
                          AppFonts.aclonica,
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 48.sp,
                        ),),
                        SizedBox(height: 2.h),
                        // Button
                        AppButton(text: 'ابدأ اللعبه', onPressed: () async {
                          // إعادة تحميل البيانات من التخزين المحلي أولاً
                          print('🔄 إعادة تحميل البيانات من التخزين المحلي...');
                          await GlobalStorage.loadData();

                          // إذا كان هناك token، حاول جلب بيانات المستخدم من API للحصول على أحدث البيانات
                          if (GlobalStorage.token.isNotEmpty) {
                            print('🔄 جلب بيانات المستخدم من API...');
                            try {
                              final authCubit = getIt<AuthCubit>();
                              await authCubit.getProfile();

                              // انتظار تحديث الحالة
                              await Future.delayed(const Duration(milliseconds: 100));

                              final authState = authCubit.state;
                              if (authState is ProfileLoaded) {
                                final user = authState.user;
                                print('✅ تم جلب بيانات المستخدم من API:');
                                print('  - User: ${user.name}');
                                print('  - Subscription: ${user.subscription}');

                                // تحديث GlobalStorage بالبيانات الجديدة
                                GlobalStorage.user = user;
                                GlobalStorage.subscription = user.subscription;

                                // حفظ البيانات في التخزين المحلي
                                await GlobalStorage.saveUserData(user);
                                await GlobalStorage.saveSubscription(user.subscription);

                                if (user.subscription != null) {
                                  print('  - Subscription status: ${user.subscription!.status}');
                                  print('  - Subscription limit: ${user.subscription!.limit}');
                                }
                              } else {
                                print('❌ فشل في جلب بيانات المستخدم من API');
                              }
                            } catch (e) {
                              print('❌ خطأ في جلب بيانات المستخدم من API: $e');
                            }
                          }

                          // فحص الاشتراك بعد إعادة التحميل وجلب البيانات من API
                          print('🔍 فحص الاشتراك النهائي:');
                          print('  - GlobalStorage.subscription: ${GlobalStorage.subscription}');

                          if (GlobalStorage.subscription != null) {
                            print('  - Subscription status: ${GlobalStorage.subscription!.status}');
                            print('  - Subscription limit: ${GlobalStorage.subscription!.limit}');

                            // إذا كان هناك اشتراك نشط، انتقل مباشرة إلى صفحة فئات الفريق الأول
                            if (GlobalStorage.subscription!.status == 'active') {
                              print('  - ✅ اشتراك نشط: الانتقال إلى فئات الفريق الأول');
                              print('  - 🚀 الانتقال لصفحة TeamCategoriesView (فئات الفريق الأول)...');
                              print('     📋 الحد المسموح: ${GlobalStorage.subscription!.limit ?? 4} فئة');

                              context.pushReplacementNamed(
                                Routes.teamCategories,
                                argument: {'limit': GlobalStorage.subscription!.limit ?? 4},
                              );
                            } else {
                              // اشتراك غير نشط، انتقل إلى صفحة المستويات
                              print('  - ❌ اشتراك غير نشط: الانتقال إلى صفحة المستويات');
                              context.pushReplacementNamed(Routes.level);
                            }
                          } else {
                            // لا يوجد اشتراك، انتقل إلى صفحة المستويات
                            print('  - ❌ لا يوجد اشتراك: الانتقال إلى صفحة المستويات');
                            context.pushReplacementNamed(Routes.level);
                          }
                        },),

                      ],
                    ),
                  ),
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}

