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
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:guess_game/features/game/data/models/game_statistics_response.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_drawer_icon.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/yellow_pill_button.dart';

class MyRoundsView extends StatefulWidget {
  const MyRoundsView({super.key});

  @override
  State<MyRoundsView> createState() => _MyRoundsViewState();
}

class _MyRoundsViewState extends State<MyRoundsView> {
  bool _hasGameId = false;

  @override
  void initState() {
    super.initState();
    // Try to get gameId from various sources
    _loadGameStatistics();
  }

  void _loadGameStatistics() {
    int? gameId;
    
    // Try to get gameId from different sources
    // 1. From GlobalStorage.lastRouteArguments
    gameId = GlobalStorage.lastRouteArguments?['gameId'] as int?;
    
    // 2. From last game start response
    if (gameId == null) {
      final lastGameStart = GlobalStorage.lastGameStartResponse;
      if (lastGameStart != null) {
        gameId = lastGameStart.data.id;
      }
    }
    
    // 3. From current game start response
    if (gameId == null) {
      final currentGameStart = GlobalStorage.gameStartResponse;
      if (currentGameStart is GameStartResponse) {
        gameId = currentGameStart.data.id;
      }
    }
    
    if (gameId != null && gameId > 0) {
      setState(() {
        _hasGameId = true;
      });
      context.read<GameCubit>().getGameStatistics(gameId);
    } else {
      setState(() {
        _hasGameId = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content container
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: 75.h, bottom: 28.h, left: 0, right: 24.w),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: (255 * 2 + 92).w,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Background gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0XFF8e8e8e),
                                  AppColors.black.withOpacity(.2),
                                  Colors.white.withOpacity(.5),
                                ],
                              ),
                            ),
                          ),

                          // Header (painted) + title
                          Positioned(
                            top: -23,
                            left: 0,
                            child: SizedBox(
                              width: 285.w,
                              height: 80.h,
                              child: CustomPaint(painter: HeaderShapePainter()),
                            ),
                          ),
                          Positioned(
                            top: -13,
                            left: 50,
                            child: Text(
                              'جولاتي',
                              style: TextStyles.font14Secondary700Weight,
                            ),
                          ),

                          // Close button
                          Positioned(
                            top: -15,
                            right: -15,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: SvgPicture.asset(AppIcons.cancel),
                            ),
                          ),

                          // Content area
                          Positioned(
                            top: 18.h,
                            left: 10.w,
                            right: 10.w,
                            bottom: 20.h,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0XFF231F20).withOpacity(.3),
                              ),
                              child: BlocBuilder<GameCubit, GameState>(
                                builder: (context, state) {
                                  if (!_hasGameId) {
                                    return _buildNoGameIdContent();
                                  } else if (state is GameStatisticsLoading) {
                                    return _buildLoadingContent();
                                  } else if (state is GameStatisticsLoaded) {
                                    return _buildRoundsContent(state.response);
                                  } else if (state is GameStatisticsError) {
                                    return _buildErrorContent(state.message);
                                  } else {
                                    return _buildNoRoundsContent();
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
              ),
            ),

            // Drawer icon (top left)
            Positioned(
              top: 6.h,
              left: 6.w,
              child: GameDrawerIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل الجولات...',
            style: TextStyles.font16Secondary700Weight,
          ),
        ],
      ),
    );
  }

  Widget _buildRoundsContent(GameStatisticsResponse statistics) {
    final rounds = statistics.data.rounds;
    final teams = statistics.data.teams;

    if (rounds.isEmpty) {
      return _buildNoRoundsContent();
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game info header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.8),
                  AppColors.primaryColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اللعبة: ${statistics.data.game.name}',
                  style: TextStyles.font14Secondary700Weight,
                ),
                SizedBox(height: 4.h),
                Text(
                  'إجمالي الجولات: ${statistics.data.statistics.totalRounds}',
                  style: TextStyles.font12Secondary700Weight.copyWith(
                    color: AppColors.secondaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Rounds list
          Expanded(
            child: ListView.builder(
              itemCount: rounds.length,
              itemBuilder: (context, index) {
                final round = rounds[index];
                return _buildRoundCard(round, teams);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundCard(GameStatisticsRound round, List<GameStatisticsTeam> teams) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue.withOpacity(0.7),
            AppColors.darkBlue.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الجولة رقم ${round.roundNumber}',
                style: TextStyles.font16Secondary700Weight,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'ID: ${round.roundId}',
                  style: TextStyles.font10Secondary700Weight,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Teams data
          ...round.teamsData.map((teamData) => _buildTeamDataRow(teamData)),
          
          SizedBox(height: 12.h),

          // Replay button
          Align(
            alignment: Alignment.centerRight,
            child: YellowPillButton(
              width: 140.w,
              height: 32.h,
              onTap: () => _replayGame(round, teams),
              child: Text(
                'تكرار لعب الجيم',
                style: TextStyles.font12Secondary700Weight,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamDataRow(GameStatisticsRoundTeamData teamData) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الفريق: ${teamData.teamName}',
                style: TextStyles.font14Secondary700Weight,
              ),
              Text(
                'النقاط: ${teamData.pointEarned}',
                style: TextStyles.font12Secondary700Weight.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'الفئة: ${teamData.categoryName}',
            style: TextStyles.font12Secondary700Weight.copyWith(
              color: AppColors.secondaryColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الحالة: ${_getStatusText(teamData.status)}',
                style: TextStyles.font10Secondary700Weight.copyWith(
                  color: _getStatusColor(teamData.status),
                ),
              ),
              Text(
                'الأسئلة: ${teamData.answerNumber}/${teamData.maxAnswers}',
                style: TextStyles.font10Secondary700Weight.copyWith(
                  color: AppColors.secondaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoGameIdContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64.w,
            color: AppColors.secondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد ألعاب متاحة',
            style: TextStyles.font16Secondary700Weight,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'يجب لعب لعبة واحدة على الأقل لعرض الجولات',
            style: TextStyles.font14Secondary700Weight.copyWith(
              color: AppColors.secondaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          YellowPillButton(
            width: 140.w,
            height: 32.h,
            onTap: () {
              Navigator.of(context).pushNamed(Routes.level);
            },
            child: Text(
              'ابدأ لعبة جديدة',
              style: TextStyles.font12Secondary700Weight,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRoundsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports,
            size: 64.w,
            color: AppColors.secondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد جولات',
            style: TextStyles.font16Secondary700Weight,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم العثور على أي جولات مسجلة',
            style: TextStyles.font14Secondary700Weight.copyWith(
              color: AppColors.secondaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.w,
            color: Colors.red.withOpacity(0.7),
          ),
          SizedBox(height: 16.h),
          Text(
            'خطأ في تحميل البيانات',
            style: TextStyles.font16Secondary700Weight,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyles.font14Secondary700Weight.copyWith(
              color: AppColors.secondaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          YellowPillButton(
            width: 120.w,
            height: 32.h,
            onTap: () {
              _loadGameStatistics();
            },
            child: Text(
              'إعادة المحاولة',
              style: TextStyles.font12Secondary700Weight,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _replayGame(GameStatisticsRound round, List<GameStatisticsTeam> teams) {
    // Extract team names from the round data
    final team1Data = round.teamsData.isNotEmpty ? round.teamsData[0] : null;
    final team2Data = round.teamsData.length > 1 ? round.teamsData[1] : null;

    if (team1Data == null || team2Data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('بيانات الفرق غير مكتملة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save team names to GlobalStorage
    GlobalStorage.team1Name = team1Data.teamName;
    GlobalStorage.team2Name = team2Data.teamName;

    // Navigate to GroupsView with the team names
    Navigator.of(context).pushNamed(
      Routes.groups,
      arguments: {
        'team1Name': team1Data.teamName,
        'team2Name': team2Data.teamName,
        'isReplay': true,
        'roundNumber': round.roundNumber,
        'roundId': round.roundId,
      },
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'مكتملة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'pending':
        return 'في الانتظار';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return AppColors.secondaryColor;
    }
  }
}