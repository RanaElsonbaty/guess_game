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
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_drawer_icon.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:guess_game/core/helper_functions/toast_helper.dart';
import 'package:shimmer/shimmer.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> with WidgetsBindingObserver {
  bool _isIncreaseMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // التحقق من arguments عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _isIncreaseMode = args['increase'] == true;
        final fromMyRounds = args['fromMyRounds'] == true;
        
        if (fromMyRounds) {
          print('📦 تم الوصول من صفحة جولاتي - حفظ بيانات اللعبة');
          // Save the game data from MyRounds to GlobalStorage
          GlobalStorage.lastRouteArguments = Map<String, dynamic>.from(args);
        } else if (_isIncreaseMode) {
          print('📦 وضع زيادة الاشتراك مفعّل (باقه جديدة نفس الجيم)');
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Ensure packages are reloaded when returning (e.g. after payment).
      if (mounted) {
        context.read<PackagesCubit>().loadPackages();
      }
      // عند العودة للتطبيق، تحقق من البيانات
      _checkSubscriptionAndNavigate();
    }
  }

  Future<void> _checkSubscriptionAndNavigate() async {
    print('🔍 فحص حالة الاشتراك بعد العودة من الدفع...');

    // انتظار قليلاً لضمان تحديث البيانات
    await Future.delayed(const Duration(milliseconds: 500));

    // إعادة تحميل بيانات المستخدم من API
    try {
      final authCubit = getIt<AuthCubit>();
      await authCubit.getProfile();

      await Future.delayed(const Duration(milliseconds: 100));

      final authState = authCubit.state;
      if (authState is ProfileLoaded) {
        final user = authState.user;

        // تحديث GlobalStorage
        GlobalStorage.user = user;
        GlobalStorage.subscription = user.subscription;

        print('✅ تم تحديث بيانات المستخدم بعد الدفع:');
        print('  - User: ${user.name}');
        print('  - Subscription: ${user.subscription}');

        if (user.subscription != null) {
          print('  - Status: ${user.subscription!.status}');
          print('  - Used: ${user.subscription!.used}');
          print('  - Limit: ${user.subscription!.limit}');

          // حساب المتبقي
          final remaining = (user.subscription!.limit ?? 0) - (user.subscription!.used ?? 0);
          print('  - Remaining: $remaining');

          // التحقق من التوجيه
          if (user.subscription!.status == 'expired') {
            print('🎯 الاشتراك منتهي الصلاحية - البقاء في صفحة الباقات');
            // البقاء في packages_view
          } else if (remaining > 0) {
            // التحقق من مصدر الوصول
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            final fromMyRounds = args?['fromMyRounds'] == true;
            
            if (fromMyRounds) {
              print('🎯 تم الدفع من صفحة جولاتي - الانتقال مباشرة لصفحة GroupsView');
              // Navigate directly to GroupsView with saved game data
              final team1Name = args?['team1Name'] as String? ?? '';
              final team2Name = args?['team2Name'] as String? ?? '';
              final team1Categories = (args?['team1Categories'] as List<dynamic>?)?.cast<int>() ?? <int>[];
              final team2Categories = (args?['team2Categories'] as List<dynamic>?)?.cast<int>() ?? <int>[];
              
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(
                  Routes.groups,
                  arguments: {
                    'team1Name': team1Name,
                    'team2Name': team2Name,
                    'team1Categories': team1Categories,
                    'team2Categories': team2Categories,
                    'isReplay': true, // Use /games/start
                  },
                );
              }
            } else if (_isIncreaseMode) {
              print('🎯 وضع زيادة الاشتراك - الانتقال لصفحة اختيار الفئات');
              if (mounted) {
                // الحصول على gameId و teamIds من GlobalStorage
                final gameArgs = GlobalStorage.lastRouteArguments ?? <String, dynamic>{};
                final gameId = gameArgs['gameId'] as int? ?? 0;
                final team1Id = gameArgs['team1Id'] as int? ?? 0;
                final team2Id = gameArgs['team2Id'] as int? ?? 0;
                
                print('📋 بيانات اللعبة للانتقال: gameId=$gameId, team1Id=$team1Id, team2Id=$team2Id');
                print('📋 أسماء الفرق المحفوظة: team1=${GlobalStorage.team1Name}, team2=${GlobalStorage.team2Name}');
                
                // التأكد من تحميل بيانات اللعبة
                GlobalStorage.loadGameData();
                
                Navigator.of(context).pushReplacementNamed(
                  Routes.teamCategories,
                  arguments: {
                    'limit': user.subscription!.limit ?? 4,
                    'isAddOneCategory': false, // مسموح بأكثر من فئة
                    'gameId': gameId,
                    'team1Id': team1Id,
                    'team2Id': team2Id,
                    'isSameGamePackage': true, // علامة للتعرف على هذا السايكل
                  },
                );
              }
            } else {
              print('🎯 الاشتراك نشط ولديه أسئلة متبقية - الانتقال إلى TeamCategoriesFirstTeamView');
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(
                  Routes.teamCategories,
                  arguments: {
                    'limit': user.subscription!.limit ?? 4,
                  },
                );
              }
            }
          } else {
            print('🎯 الاشتراك نشط لكن انتهت الأسئلة - البقاء في صفحة الباقات');
            // البقاء في packages_view
          }
        }
      }
    } catch (e) {
      print('❌ خطأ في فحص البيانات بعد الدفع: $e');
    }
  }

  Future<void> _subscribeToPackage(Package package) async {
    try {
      // التحقق من مصدر الوصول
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final fromMyRounds = args?['fromMyRounds'] == true;
      final packageId = args?['packageId'] as int?;
      
      if (fromMyRounds) {
        // Save the MyRounds data to GlobalStorage for use after payment
        GlobalStorage.lastRouteArguments = Map<String, dynamic>.from(args ?? {});
        
        // Use the specific package ID from MyRounds
        if (packageId != null) {
          await context.read<PackagesCubit>().subscribeToPackage(packageId, increase: _isIncreaseMode);
        } else {
          await context.read<PackagesCubit>().subscribeToPackage(package.id, increase: _isIncreaseMode);
        }
      } else {
        // Normal subscription flow
        await context.read<PackagesCubit>().subscribeToPackage(package.id, increase: _isIncreaseMode);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'حدث خطأ في الاشتراك: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PackagesCubit, PackagesState>(
      listener: (context, state) {
        if (state is PackagesSubscriptionError) {
          print('❌ API Error: ${state.message}');
        } else if (state is PackagesSubscribed) {
          // الانتقال مباشرة إلى صفحة الدفع عند نجاح الاشتراك
          final url = state.paymentUrl;
          print('🎯 Payment URL received: $url');
          print('🔗 فتح صفحة الدفع مباشرة: $url');
          
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaymentWebView(url: url),
              ),
            ).then((_) {
              // بعد العودة من صفحة الدفع
              if (mounted) {
                context.read<PackagesCubit>().loadPackages();
                _checkSubscriptionAndNavigate();
              }
            });
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          drawer: const AppDrawer(),
          body: Stack(
            children: [
              // Drawer icon (top left of main page)
              Positioned(
                top: 6.h,
                left: 6.w,
                child: GameDrawerIcon(),
              ),
              // Main content - positioned to create space from drawer
              Positioned(
                top: 75.h, // نزله شوية للأسفل
                left: 70.w, // إبعاده عن الـ drawer ووضعه يمين شوية
                right: 20.w,
                child: Container(
                  width: 740.w,
                  height: 255.h,
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
                        top: -25,
                        left: 0,
                        child: SizedBox(
                          width: 285.w,
                          height: 85.h,
                          child: CustomPaint(
                            painter: HeaderShapePainter(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -20,
                        left: 35,
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
                        bottom: 0.h,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0XFF231F20).withOpacity(.3),
                          ),
                          child: BlocBuilder<PackagesCubit, PackagesState>(
                            builder: (context, state) {
                              final cubit = context.read<PackagesCubit>();
                              
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
                                // استخدام cubit.packages للحفاظ على الباقات حتى عند الاشتراك
                                final isLoading = state is PackagesLoading;
                                final packages = cubit.packages.isNotEmpty 
                                    ? cubit.packages 
                                    : (state is PackagesLoaded ? state.packages : []);

                                if (isLoading && packages.isEmpty) {
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
                                          isSubscriptionLocked: false, // الكروت في صفحة الباقات دائماً مفتوحة - مطلوب من المستخدم
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
                        )],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}