import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:guess_game/features/game/data/models/all_games_response.dart';
import 'package:guess_game/features/game/presentation/cubit/get_all_games_cubit.dart';
import 'package:guess_game/features/packages/data/repositories/packages_repository.dart';
import 'package:guess_game/features/packages/presentation/view/payment_webview.dart';
import 'package:guess_game/features/packages/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_drawer_icon.dart';
import 'package:shimmer/shimmer.dart';

class MyRoundsView extends StatefulWidget {
  const MyRoundsView({super.key});

  @override
  State<MyRoundsView> createState() => _MyRoundsViewState();
}

class _MyRoundsViewState extends State<MyRoundsView> {
  final Map<String, bool> _expandedGames = {};
  final Map<String, bool> _expandedPackages = {};
  final Map<String, bool> _expandedRounds = {};

  @override
  void initState() {
    super.initState();
    context.read<GetAllGamesCubit>().getAllGames();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'expired':
        return 'منتهي الصلاحية';
      case 'pending':
        return 'في الانتظار';
      default:
        return status;
    }
  }

  void _subscribeToPackage(PackageData package, GameItem game) {
    // Extract team data from ALL rounds of the package
    if (package.rounds.isNotEmpty) {
      // Collect all categories from all rounds for each team
      final Map<int, Set<int>> teamCategoriesMap = {};
      final Map<int, String> teamNamesMap = {};
      
      // Process all rounds to collect categories
      for (final round in package.rounds) {
        for (final item in round.roundData) {
          final teamNumber = item.team?.teamNumber ?? 0;
          
          // Initialize team data if not exists
          if (!teamCategoriesMap.containsKey(teamNumber)) {
            teamCategoriesMap[teamNumber] = <int>{};
            // Extract clean team name without "فريق" prefix
            String cleanTeamName = item.team?.name ?? '';
            if (cleanTeamName.startsWith('فريق ')) {
              cleanTeamName = cleanTeamName.substring(5).trim();
            }
            if (cleanTeamName.isEmpty) {
              cleanTeamName = teamNumber == 1 ? 'الأول' : 'الثاني';
            }
            teamNamesMap[teamNumber] = cleanTeamName;
          }
          
          // Add category to team's set (Set automatically handles duplicates)
          teamCategoriesMap[teamNumber]!.add(item.categoryId);
        }
      }

      // Extract team names, categories, and team numbers
      String team1Name = teamNamesMap[1] ?? 'الأول';
      String team2Name = teamNamesMap[2] ?? 'الثاني';
      
      // Remove "فريق" prefix if it exists in the team names
      if (team1Name.startsWith('فريق ')) {
        team1Name = team1Name.substring(5).trim(); // Remove "فريق " (5 characters)
      }
      if (team2Name.startsWith('فريق ')) {
        team2Name = team2Name.substring(5).trim(); // Remove "فريق " (5 characters)
      }
      
      // If team name is empty after removing prefix, use default
      if (team1Name.isEmpty) team1Name = 'الأول';
      if (team2Name.isEmpty) team2Name = 'الثاني';
      List<int> team1Categories = teamCategoriesMap[1]?.toList() ?? [];
      List<int> team2Categories = teamCategoriesMap[2]?.toList() ?? [];
      int team1Number = 1;
      int team2Number = 2;

      print('🎯 الاشتراك في الباقة: ${package.name}');
      print('📋 بيانات الفرق من جميع الجولات (${package.rounds.length} جولة):');
      print('  - الفريق الأول: $team1Name (رقم: $team1Number), الفئات: $team1Categories');
      print('  - الفريق الثاني: $team2Name (رقم: $team2Number), الفئات: $team2Categories');
      print('📊 إجمالي الفئات المجمعة:');
      print('  - فريق 1: ${team1Categories.length} فئة');
      print('  - فريق 2: ${team2Categories.length} فئة');

      // Navigate directly to PaymentWebView with subscription
      _performSubscription(package, {
        'fromMyRounds': true,
        'packageId': package.id,
        'team1Name': team1Name,
        'team2Name': team2Name,
        'team1Categories': team1Categories,
        'team2Categories': team2Categories,
        'team1Number': team1Number,
        'team2Number': team2Number,
        'paymentMethod': 'online',
        'packageLimit': package.limit, // إضافة حد الباقة
        'totalRounds': package.rounds.length, // إضافة عدد الجولات
      });
    }
  }

  Future<void> _performSubscription(PackageData package, Map<String, dynamic> gameData) async {
    try {
      // Save game data to GlobalStorage
      GlobalStorage.lastRouteArguments = Map<String, dynamic>.from(gameData);
      
      print('💾 حفظ بيانات اللعبة في GlobalStorage: $gameData');
      
      // Call the subscription API directly
      final packagesRepository = getIt<PackagesRepository>();
      final result = await packagesRepository.subscribeToPackage(package.id, increase: false);
      
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في الاشتراك: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (paymentUrl) {
          print('🎯 تم الحصول على رابط الدفع: $paymentUrl');
          
          // Navigate to PaymentWebView
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaymentWebView(url: paymentUrl),
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ خطأ في عملية الاشتراك: $e');
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

  Widget _buildRoundDetails(List<RoundData> rounds, String packageKey) {
    return Column(
      children: rounds.map((round) {
        final roundKey = '${packageKey}_round_${round.id}';
        final isRoundExpanded = _expandedRounds[roundKey] ?? false;
        
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Round header - clickable
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedRounds[roundKey] = !isRoundExpanded;
                  });
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'الجولة ${round.roundNumber}',
                        style: TextStyles.font14Secondary700Weight.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      isRoundExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
              // Round details - expandable
              AnimatedSize(
                duration: Duration(milliseconds: 300),
                child: isRoundExpanded
                    ? Container(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Column(
                          children: round.roundData.map((item) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.team?.name?.replaceFirst('فريق ', '') ?? 'فريق ${item.team?.teamNumber ?? 0}'}: ${item.category?.name ?? 'فئة غير محددة'}',
                                      style: TextStyles.font12Secondary700Weight.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.pointEarned} نقطة',
                                    style: TextStyles.font12Secondary700Weight.copyWith(
                                      color: item.pointEarned >= 0 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                height: 255.h, // نفس ارتفاع صفحة الباقات
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
                        'جولاتي',
                        style: TextStyles.font14Secondary700Weight,
                      ),
                    ),
                    /// Close button (top right of main container)
                    Positioned(
                      top: -15,
                      right: -15,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(AppIcons.cancel),
                      ),
                    ),
                    /// Content container
                    Positioned(
                      top: 18.h,
                      left: 10.w,
                      right: 10.w,
                      bottom: 0.h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0XFF231F20).withOpacity(.3),
                        ),
                        child: BlocBuilder<GetAllGamesCubit, GetAllGamesState>(
                          builder: (context, state) {
                            if (state is GetAllGamesLoading) {
                              return _buildShimmerLoading();
                            } else if (state is GetAllGamesError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'خطأ في تحميل البيانات',
                                      style: TextStyles.font16Secondary700Weight.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      state.message,
                                      style: TextStyles.font14Secondary700Weight.copyWith(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 20.h),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<GetAllGamesCubit>().getAllGames();
                                      },
                                      child: Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              );
                            } else if (state is GetAllGamesLoaded) {
                              if (state.response.data.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.games_outlined,
                                        size: 80.sp,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      SizedBox(height: 20.h),
                                      Text(
                                        'لا توجد جولات متاحة',
                                        style: TextStyles.font20Secondary700Weight.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        'ابدأ لعبة جديدة لرؤية جولاتك هنا',
                                        style: TextStyles.font14Secondary700Weight.copyWith(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Padding(
                                padding: EdgeInsets.all(12.w),
                                child: ListView.builder(
                                  itemCount: state.response.data.length,
                                  itemBuilder: (context, gameIndex) {
                                    final game = state.response.data[gameIndex];
                                    final gameKey = 'game_${game.id}';
                                    final isGameExpanded = _expandedGames[gameKey] ?? false;
                                    
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 16.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        children: [
                                          // Game header - clickable
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _expandedGames[gameKey] = !isGameExpanded;
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(16.w),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12.r),
                                                  topRight: Radius.circular(12.r),
                                                  bottomLeft: isGameExpanded ? Radius.zero : Radius.circular(12.r),
                                                  bottomRight: isGameExpanded ? Radius.zero : Radius.circular(12.r),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          game.name,
                                                          style: TextStyles.font16Secondary700Weight.copyWith(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                                              decoration: BoxDecoration(
                                                                color: game.status == 'completed' ? Colors.green : Colors.orange,
                                                                borderRadius: BorderRadius.circular(4.r),
                                                              ),
                                                              child: Text(
                                                                game.status == 'completed' ? 'مكتملة' : 'قيد التقدم',
                                                                style: TextStyles.font12Secondary700Weight.copyWith(
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 8.w),
                                                            Text(
                                                              '${game.packages.length} باقة',
                                                              style: TextStyles.font12Secondary700Weight.copyWith(
                                                                color: Colors.white.withOpacity(0.7),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    isGameExpanded ? Icons.expand_less : Icons.expand_more,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Game content - expandable
                                          AnimatedSize(
                                            duration: Duration(milliseconds: 300),
                                            child: isGameExpanded
                                                ? Column(
                                                    children: game.packages.map((package) {
                                                      final packageKey = '${gameKey}_package_${package.id}';
                                                      final isPackageExpanded = _expandedPackages[packageKey] ?? false;
                                                      
                                                      return Container(
                                                        margin: EdgeInsets.all(8.w),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.05),
                                                          borderRadius: BorderRadius.circular(8.r),
                                                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            // Package header - clickable
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  _expandedPackages[packageKey] = !isPackageExpanded;
                                                                });
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.all(12.w),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            package.name,
                                                                            style: TextStyles.font14Secondary700Weight.copyWith(
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                          SizedBox(height: 4.h),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                'السعر: ${package.price} ريال',
                                                                                style: TextStyles.font12Secondary700Weight.copyWith(
                                                                                  color: Colors.white.withOpacity(0.8),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 16.w),
                                                                              Text(
                                                                                'الحد الأقصى: ${package.limit}',
                                                                                style: TextStyles.font12Secondary700Weight.copyWith(
                                                                                  color: Colors.white.withOpacity(0.8),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(height: 4.h),
                                                                          Row(
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                                                decoration: BoxDecoration(
                                                                                  color: _getStatusColor(package.subscriptionStatus),
                                                                                  borderRadius: BorderRadius.circular(4.r),
                                                                                ),
                                                                                child: Text(
                                                                                  _getStatusText(package.subscriptionStatus),
                                                                                  style: TextStyles.font10Secondary700Weight.copyWith(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 8.w),
                                                                              Text(
                                                                                '${package.rounds.length} جولة',
                                                                                style: TextStyles.font12Secondary700Weight.copyWith(
                                                                                  color: Colors.white.withOpacity(0.7),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Icon(
                                                                      isPackageExpanded ? Icons.expand_less : Icons.expand_more,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            // Package content - expandable
                                                            AnimatedSize(
                                                              duration: Duration(milliseconds: 300),
                                                              child: isPackageExpanded
                                                                  ? Container(
                                                                      padding: EdgeInsets.all(12.w),
                                                                      child: Column(
                                                                        children: [
                                                                          // Rounds
                                                                          if (package.rounds.isNotEmpty) ...[
                                                                            _buildRoundDetails(package.rounds, packageKey),
                                                                            SizedBox(height: 12.h),
                                                                          ],
                                                                          // Subscribe button
                                                                          SizedBox(
                                                                            width: double.infinity,
                                                                            child: ElevatedButton(
                                                                              onPressed: () => _subscribeToPackage(package, game),
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: Color(0xFF79899f),
                                                                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8.r),
                                                                                ),
                                                                              ),
                                                                              child: Text(
                                                                                'تكرار اللعب',
                                                                                style: TextStyles.font14Secondary700Weight.copyWith(
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : SizedBox.shrink(),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      ),
    );
  }
}