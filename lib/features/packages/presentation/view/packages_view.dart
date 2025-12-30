import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/auth_cubit.dart';
import 'package:guess_game/features/packages/presentation/cubit/packages_cubit.dart';
import 'package:guess_game/features/packages/presentation/data/models/package.dart';
import 'package:guess_game/features/packages/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/packages/presentation/view/widgets/package_card.dart';
import 'package:guess_game/features/packages/presentation/view/payment_webview.dart';
import 'package:shimmer/shimmer.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  Future<void> _subscribeToPackage(Package package) async {
    try {
      // إظهار رسالة تحميل
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري إعداد صفحة الدفع...'),
          duration: Duration(seconds: 2),
        ),
      );

      await context.read<PackagesCubit>().subscribeToPackage(package.id);

      final cubit = context.read<PackagesCubit>();
      if (cubit.paymentUrl != null) {
        final url = cubit.paymentUrl!;

        // Log the payment URL and subscription status
        print('🎯 Payment URL received: $url');
        print('📊 Subscription status after payment:');
        print('  - GlobalStorage.subscription: ${GlobalStorage.subscription}');
        print('  - Subscription != null: ${GlobalStorage.subscription != null}');
        if (GlobalStorage.subscription != null) {
          print('  - Subscription details:');
          print('    - ID: ${GlobalStorage.subscription!.id}');
          print('    - Status: ${GlobalStorage.subscription!.status}');
          print('    - Limit: ${GlobalStorage.subscription!.limit}');
        }

        // فتح صفحة الدفع
        print('🔗 فتح صفحة الدفع: $url');

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentWebView(url: url),
            ),
          );
        }

        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في الاشتراك: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshProfileAfterPayment() async {
    try {
      print('🔄 إعادة جلب profile بعد الدفع...');
      final authCubit = getIt<AuthCubit>();
      await authCubit.getProfile();

      // انتظار تحديث البيانات
      await Future.delayed(const Duration(milliseconds: 500));

      final authState = authCubit.state;
      if (authState is ProfileLoaded) {
        final user = authState.user;
        // تحديث GlobalStorage بالبيانات الجديدة
        GlobalStorage.user = user;
        GlobalStorage.subscription = user.subscription;

        // حفظ البيانات في التخزين المحلي
        await GlobalStorage.saveUserData(user);
        await GlobalStorage.saveSubscription(user.subscription);

        print('✅ تم تحديث subscription بعد الدفع:');
        print('  - Subscription: ${GlobalStorage.subscription}');
        if (GlobalStorage.subscription != null) {
          print('  - Status: ${GlobalStorage.subscription!.status}');
          print('  - Limit: ${GlobalStorage.subscription!.limit}');
        }

        // الانتقال لصفحة فئات الفريق إذا كان هناك اشتراك نشط
        print('🔍 فحص الاشتراك بعد إعادة التحميل:');
        print('  - GlobalStorage.subscription: ${GlobalStorage.subscription}');
        if (GlobalStorage.subscription != null) {
          print('  - Subscription status: ${GlobalStorage.subscription!.status}');
          print('  - Subscription limit: ${GlobalStorage.subscription!.limit}');
        }

        if (GlobalStorage.subscription != null && mounted) {
          if (GlobalStorage.subscription!.status == 'active') {
            print('🚀 الانتقال لصفحة TeamCategoriesView (فئات الفريق الأول) - اشتراك نشط...');
            print('   📋 الحد المسموح: ${GlobalStorage.subscription!.limit ?? 4} فئة');
            Navigator.of(context).pushReplacementNamed(
              Routes.teamCategories,
              arguments: GlobalStorage.subscription!.limit ?? 0,
            );
          } else {
            print('⚠️ الاشتراك منتهي الصلاحية، البقاء في صفحة الباقات للتجديد');
            // يمكن إضافة رسالة للمستخدم هنا
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('انتهت صلاحية اشتراكك. يرجى تجديد الاشتراك.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          print('⚠️ لا يوجد اشتراك، البقاء في صفحة الباقات');
        }
      }
    } catch (e) {
      print('❌ خطأ في إعادة جلب profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // إعادة جلب profile عند فتح صفحة الباقات (بعد العودة من الدفع)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfileAfterPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PackagesCubit, PackagesState>(
      listener: (context, state) {
        if (state is PackagesSubscriptionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الاشتراك: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            width: 740.w,
            height: 280.h,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /// Background gradient
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
                /// Header (painted) INSIDE main container
                Positioned(
                  top: -23,
                  left: 0,
                  child: SizedBox(
                    width: 260.w,
                    height: 80.h,
                    child: CustomPaint(
                      painter: HeaderShapePainter(),
                    ),
                  ),
                ),
                Positioned(
                  top: -13,
                  left: 25,
                  child: Text(
                    'الباقات',
                    style: TextStyles.font14Secondary700Weight,
                  ),
                ),
                /// Close button (top right of main container)
                Positioned(
                  top: -15,
                  right: -15,
                  child: SvgPicture.asset(AppIcons.cancel),
                ),
                /// Packages container
                Positioned(
                  top: 18.h,
                  left: 10.w,
                  right: 10.w,
                  bottom: 20.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0XFF231F20).withOpacity(.3),
                    ),
                    child: BlocBuilder<PackagesCubit, PackagesState>(
                      builder: (context, state) {
                        if (state is PackagesError) {
                          return Center(
                            child: Text(
                              'خطأ في تحميل الباقات: ${state.message}',
                              style: TextStyles.font14Secondary700Weight.copyWith(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          // Show shimmer or real packages
                          final isLoading = state is PackagesLoading;
                          final packages = state is PackagesLoaded ? state.packages : [];

                          if (isLoading) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 10.h, // تقليل الـ padding العمودي
                                    ),
                                    child: const PackageCard(
                                      title: 'تحميل...',
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              itemCount: packages.length,
                              itemBuilder: (context, index) {
                                final package = packages[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 18.h, // تقليل الـ padding العمودي بسبب زيادة ارتفاع الكارت
                                  ),
                                  child: PackageCard(
                                    package: package,
                                    onPressed: () => _subscribeToPackage(package),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}