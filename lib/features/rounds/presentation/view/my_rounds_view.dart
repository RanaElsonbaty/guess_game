import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:guess_game/features/game/data/models/all_games_response.dart';
import 'package:guess_game/features/game/presentation/cubit/get_all_games_cubit.dart';
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
  final Map<String, bool> _expandedRounds = {};
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    context.read<GetAllGamesCubit>().getAllGames();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreGames();
      }
    }
  }

  void _loadMoreGames() {
    setState(() {
      _isLoadingMore = true;
    });
    
    // Load next page
    _currentPage++;
    // Call API with page parameter
    // context.read<GetAllGamesCubit>().getAllGames(page: _currentPage);
    
    // For now, just reset the loading state
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  void _subscribeToGame(GameItem game) {
    // Extract team data from game.teams
    if (game.teams.isNotEmpty) {
      // Get team names and numbers
      final team1 = game.teams.firstWhere((t) => t.teamNumber == 1, orElse: () => game.teams.first);
      final team2 = game.teams.firstWhere((t) => t.teamNumber == 2, orElse: () => game.teams.last);
      
      String team1Name = team1.name;
      String team2Name = team2.name;
      int team1Number = team1.teamNumber;
      int team2Number = team2.teamNumber;

      print('🎯 تكرار اللعب للجيم: ${game.name}');
      print('📋 بيانات الفرق:');
      print('  - الفريق الأول: "$team1Name" (رقم: $team1Number)');
      print('  - الفريق الثاني: "$team2Name" (رقم: $team2Number)');
      print('📦 game.teams.length: ${game.teams.length}');
      print('📦 team1 object: id=${team1.id}, name="${team1.name}", teamNumber=${team1.teamNumber}');
      print('📦 team2 object: id=${team2.id}, name="${team2.name}", teamNumber=${team2.teamNumber}');

      // Save team names to GlobalStorage
      GlobalStorage.team1Name = team1Name;
      GlobalStorage.team2Name = team2Name;
      
      // Clear categories to allow user to select new ones
      GlobalStorage.team1Categories = [];
      GlobalStorage.team2Categories = [];

      print('🚀 Navigating to GroupsView with:');
      print('   team1Name: "$team1Name"');
      print('   team2Name: "$team2Name"');

      // Navigate to GroupsView with team data
      Navigator.of(context).pushNamed(
        Routes.groups,
        arguments: {
          'isReplay': true,
          'gameId': game.id,
          'team1Name': team1Name, // Use team name not number
          'team2Name': team2Name, // Use team name not number
          'team1Number': team1Number,
          'team2Number': team2Number,
          'team1Categories': [],
          'team2Categories': [],
        },
      );
    }
  }

  Widget _buildRoundDetails(List<RoundData> rounds, String gameKey, List<TeamInfo> teams) {
    return Column(
      children: rounds.map((round) {
        final roundKey = '${gameKey}_round_${round.id}';
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      isRoundExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.secondaryColor,
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
                            // Find team by team_id
                            final team = teams.firstWhere(
                              (t) => t.id == item.teamId,
                              orElse: () => teams.first,
                            );
                            
                            // Get category name
                            final categoryName = item.category?.name ?? 'فئة ${item.categoryId}';
                            
                            return Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${team.name}: $categoryName',
                                      style: TextStyles.font12Secondary700Weight,
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
              top: 75.h,
              left: 70.w,
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
                                      style: TextStyles.font16Secondary700Weight,
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      state.message,
                                      style: TextStyles.font14Secondary700Weight,
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
                              // Update pagination info from meta_data
                              if (state.response.metaData != null) {
                                final metaData = state.response.metaData!;
                                final currentPage = metaData['current_page'] ?? 1;
                                final lastPage = metaData['last_page'] ?? 1;
                                _hasMoreData = currentPage < lastPage;
                              }
                              
                              if (state.response.data.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.games_outlined,
                                        size: 80.sp,
                                        color: AppColors.secondaryColor,
                                      ),
                                      SizedBox(height: 20.h),
                                      Text(
                                        'لا توجد جولات متاحة',
                                        style: TextStyles.font20Secondary700Weight,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        'ابدأ لعبة جديدة لرؤية جولاتك هنا',
                                        style: TextStyles.font14Secondary700Weight,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Padding(
                                padding: EdgeInsets.all(12.w),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: state.response.data.length + (_isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, gameIndex) {
                                    // Show loading indicator at the end
                                    if (gameIndex == state.response.data.length) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.h),
                                          child: CircularProgressIndicator(
                                            color: AppColors.secondaryColor,
                                          ),
                                        ),
                                      );
                                    }
                                    
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
                                                          style: TextStyles.font16Secondary700Weight,
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        Text(
                                                          '${game.rounds.length} جولة',
                                                          style: TextStyles.font12Secondary700Weight,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    isGameExpanded ? Icons.expand_less : Icons.expand_more,
                                                    color: AppColors.secondaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Game content - expandable
                                          AnimatedSize(
                                            duration: Duration(milliseconds: 300),
                                            child: isGameExpanded
                                                ? Container(
                                                    padding: EdgeInsets.all(12.w),
                                                    child: Column(
                                                      children: [
                                                        // Rounds
                                                        if (game.rounds.isNotEmpty) ...[
                                                          _buildRoundDetails(game.rounds, gameKey, game.teams),
                                                          SizedBox(height: 12.h),
                                                        ],
                                                        // Repeat game button
                                                        GestureDetector(
                                                          onTap: () => _subscribeToGame(game),
                                                          child: Container(
                                                            margin: EdgeInsets.symmetric(vertical: 5.h),
                                                            height: 40.h,
                                                            width: double.infinity,
                                                            child: Stack(
                                                              alignment: Alignment.bottomCenter,
                                                              children: [
                                                                /// Bottom Gradient Shadow
                                                                Positioned(
                                                                  bottom: 0,
                                                                  left: 10.w,
                                                                  right: 10.w,
                                                                  child: Container(
                                                                    height: 6.h,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.vertical(
                                                                        bottom: Radius.circular(20.r),
                                                                      ),
                                                                      gradient: const LinearGradient(
                                                                        begin: Alignment.topCenter,
                                                                        end: Alignment.bottomCenter,
                                                                        colors: [
                                                                          AppColors.gradiant1,
                                                                          AppColors.gradiant2,
                                                                          AppColors.gradiant3,
                                                                          AppColors.gradiant4,
                                                                          AppColors.gradiant5
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                /// External Bottom Border
                                                                Positioned(
                                                                  bottom: 0,
                                                                  left: 0,
                                                                  right: 0,
                                                                  child: Container(
                                                                    height: 5.h,
                                                                    decoration: BoxDecoration(
                                                                      color: AppColors.buttonEternalBorder,
                                                                      borderRadius: BorderRadius.vertical(
                                                                        bottom: Radius.circular(18.r),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                /// Inner Bottom Border
                                                                Positioned(
                                                                  bottom: 2.h,
                                                                  left: 6.w,
                                                                  right: 6.w,
                                                                  child: Container(
                                                                    height: 4.h,
                                                                    decoration: BoxDecoration(
                                                                      color: AppColors.buttonInnerBorder,
                                                                      borderRadius: BorderRadius.vertical(
                                                                        bottom: Radius.circular(14.r),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                /// Main Button Body
                                                                Container(
                                                                  height: 55.h,
                                                                  decoration: BoxDecoration(
                                                                    color: AppColors.buttonYellow,
                                                                    borderRadius: BorderRadius.circular(15.r),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: AppColors.buttonEternalBorder,
                                                                        offset: const Offset(0, 3),
                                                                        blurRadius: 0,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  alignment: Alignment.center,
                                                                  child: Text(
                                                                    'تكرار اللعب',
                                                                    style: TextStyles.font16Secondary700Weight,
                                                                  ),
                                                                ),
                                                              ],
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
