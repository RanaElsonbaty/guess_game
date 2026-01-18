import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/game/data/models/game_statistics_response.dart';
import 'package:guess_game/features/game/data/models/assign_winner_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_response.dart';
import 'package:guess_game/features/game/data/models/update_score_response.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/score_medal_box.dart';
import 'package:guess_game/guess_game.dart';

class GameWinnerView extends StatefulWidget {
  const GameWinnerView({super.key});

  @override
  State<GameWinnerView> createState() => _GameWinnerViewState();
}

class _GameWinnerViewState extends State<GameWinnerView> {
  UpdatePointPlanResponse? _pointPlanResponse;
  UpdateScoreResponse? _scoreResponse;
  AssignWinnerResponse? _assignWinnerResponse;
  bool _didReadArgs = false;
  bool _didLoadStats = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;

    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Map<String, dynamic>? globalArgs =
        GuessGame.globalInitialArguments as Map<String, dynamic>?;

    if (kDebugMode) {
      print('🏆 GameWinnerView: args = $args');
      print('🏆 GameWinnerView: globalArgs = $globalArgs');
    }

    final effectiveArgs = args ?? globalArgs;
    _pointPlanResponse = effectiveArgs?['updatePointPlanResponse'];
    _scoreResponse = effectiveArgs?['updateScoreResponse'];
    _assignWinnerResponse = effectiveArgs?['assignWinnerResponse'];

    if (kDebugMode) {
      print('🏆 GameWinnerView: didChangeDependencies completed');
      print('🏆 GameWinnerView: _pointPlanResponse: ${_pointPlanResponse != null}');
      print('🏆 GameWinnerView: _scoreResponse: ${_scoreResponse != null}');
      print('🏆 GameWinnerView: _assignWinnerResponse: ${_assignWinnerResponse != null}');
    }
  }

  Map<String, int> _extractTeamScores() {
    // Highest priority: assign-winner response (most up-to-date with winner assignment)
    final assignWinnerData = _assignWinnerResponse?.data.roundData;
    if (assignWinnerData != null && assignWinnerData.isNotEmpty) {
      // Keep API order: first item = Team 01, second item = Team 02.
      final team01 = assignWinnerData.isNotEmpty ? assignWinnerData[0] : null;
      final team02 = assignWinnerData.length > 1 ? assignWinnerData[1] : null;
      return {
        'team01': team01?.pointEarned ?? 0,
        'team02': team02?.pointEarned ?? 0,
      };
    }

    // Second priority: update-score response (it contains point_earned per team in data[]).
    final scoreData = _scoreResponse?.data;
    if (scoreData != null && scoreData.isNotEmpty) {
      // Keep API order: first item = Team 01, second item = Team 02.
      final team01 = scoreData.isNotEmpty ? scoreData[0] : null;
      final team02 = scoreData.length > 1 ? scoreData[1] : null;
      return {
        'team01': team01?.pointEarned ?? 0,
        'team02': team02?.pointEarned ?? 0,
      };
    }

    // Fallback: update-point-plan response (it contains point_earned per team in round_data).
    final roundData = _pointPlanResponse?.data.roundData;
    if (roundData != null && roundData.isNotEmpty) {
      // Important: keep API order to avoid swapping Team 01/02 when teamId is not a simple 1/2.
      // Convention in the app: first item = Team 01, second item = Team 02.
      final team01 = roundData.isNotEmpty ? roundData[0] : null;
      final team02 = roundData.length > 1 ? roundData[1] : null;
      return {
        'team01': team01?.pointEarned ?? 0,
        'team02': team02?.pointEarned ?? 0,
      };
    }
    return const {'team01': 0, 'team02': 0};
  }

  int _resolveGameId() {
    final fromPointPlan = _pointPlanResponse?.data.gameId ?? 0;
    if (fromPointPlan != 0) return fromPointPlan;
    final fromAssignWinner = _assignWinnerResponse?.data.gameId ?? 0;
    if (fromAssignWinner != 0) return fromAssignWinner;
    return 0;
  }

  ({String winnerName, int winnerScore, bool isWinner}) _winnerFromStatistics(
    GameStatisticsResponse stats,
  ) {
    final teams = stats.data.teams;
    final explicitWinner = teams.where((t) => t.isWinner).toList();
    if (explicitWinner.isNotEmpty) {
      final t = explicitWinner.first;
      return (winnerName: t.name, winnerScore: t.totalPoints, isWinner: true);
    }
    if (teams.length >= 2) {
      final t1 = teams[0];
      final t2 = teams[1];
      if (t1.totalPoints != t2.totalPoints) {
        final t = t1.totalPoints > t2.totalPoints ? t1 : t2;
        return (winnerName: t.name, winnerScore: t.totalPoints, isWinner: true);
      }
    }
    return (winnerName: 'تعادل', winnerScore: 0, isWinner: false);
  }

  @override
  Widget build(BuildContext context) {
    final teamScores = _extractTeamScores();
    final team01Score = teamScores['team01'] ?? 0;
    final team02Score = teamScores['team02'] ?? 0;

    // Determine winner: check AssignWinnerResponse first, then fallback to score comparison
    int winnerTeam = 0; // 0 = draw, 1 = team1, 2 = team2
    if (_assignWinnerResponse != null && _assignWinnerResponse!.data.roundData.isNotEmpty) {
      for (final roundData in _assignWinnerResponse!.data.roundData) {
        if (roundData.team.isWinner) {
          winnerTeam = roundData.team.teamNumber;
          break;
        }
      }
    } else {
      // Fallback to score comparison if no AssignWinnerResponse
      winnerTeam = team01Score > team02Score ? 1 : team02Score > team01Score ? 2 : 0;
    }

    final fallbackWinnerName = winnerTeam == 1
        ? (GlobalStorage.team1Name.isNotEmpty ? GlobalStorage.team1Name : 'الفريق الأول')
        : winnerTeam == 2
            ? (GlobalStorage.team2Name.isNotEmpty ? GlobalStorage.team2Name : 'الفريق الثاني')
            : 'تعادل';
    final fallbackWinnerScore = winnerTeam == 1 ? team01Score : winnerTeam == 2 ? team02Score : 0;
    final fallbackIsWinner = winnerTeam != 0;

    final gameId = _resolveGameId();
    if (!_didLoadStats && gameId != 0) {
      _didLoadStats = true;
      context.read<GameCubit>().getGameStatistics(gameId);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const Drawer(),
      body: SafeArea(
        child: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            final stats = context.read<GameCubit>().gameStatisticsResponse;
            final fromStats = stats != null ? _winnerFromStatistics(stats) : null;
            final winnerName = fromStats?.winnerName ?? fallbackWinnerName;
            final winnerScore = fromStats?.winnerScore ?? fallbackWinnerScore;
            final isWinner = fromStats?.isWinner ?? fallbackIsWinner;

            return Stack(
              children: [
            // Main centered card, with reserved space for drawer (top) and next button (bottom)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 90.h,
                  bottom: 75.h,
                  left: 24.w,
                  right: 24.w,
                ),
                child: Center(
                  child: Container(
                  width: 740.w,
                  height: 280.h,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      /// Background gradient (same as RoundWinnerView)
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

                      /// Header (painted) INSIDE main container
                      Positioned(
                        top: -23,
                        left: 0,
                        child: SizedBox(
                          width: 285.w,
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
                          'الفائز؟',
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

                      /// Content container (same as RoundWinnerView)
                      Positioned(
                        top: 18.h,
                        left: 10.w,
                        right: 10.w,
                        bottom: 20.h,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0XFF231F20).withOpacity(.3),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'الفريق الفائز',
                                style: TextStyles.font16Secondary700Weight,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                winnerName,
                                style: TextStyles.font20Secondary700Weight,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              ScoreMedalBox(
                                score: winnerScore,
                                isWinner: isWinner,
                                size: 85,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),

            // Drawer icon (top left)
            Positioned(
              top: 6.h,
              left: 6.w,
              child: Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      width: 64.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppIcons.list,
                        height: 24.h,
                        width: 36.w,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next button (bottom right)
            Positioned(
              bottom: 40,
              right: 40,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.level,
                    (route) => false,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 36,
                      width: 90,
                      decoration: const BoxDecoration(
                        color: AppColors.buttonYellow,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'التالي',
                        style: TextStyles.font10Secondary700Weight,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: AppColors.buttonBorderOrange,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: AppColors.buttonBorderOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
              ],
            );
          },
        ),
      ),
    );
  }
}
