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
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_bottom_right_button.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_drawer_icon.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
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

  ({int team1Id, int team2Id}) _resolveTeamIdsFromStatsOrFallback(GameStatisticsResponse? stats) {
    if (stats != null && stats.data.teams.isNotEmpty) {
      final t1 = stats.data.teams.where((t) => t.teamNumber == 1).toList();
      final t2 = stats.data.teams.where((t) => t.teamNumber == 2).toList();
      final team1Id = t1.isNotEmpty ? t1.first.teamId : 0;
      final team2Id = t2.isNotEmpty ? t2.first.teamId : 0;
      return (team1Id: team1Id, team2Id: team2Id);
    }

    // Fallback 1: AssignWinnerResponse has teamNumber + teamId.
    final roundData = _assignWinnerResponse?.data.roundData ?? const [];
    if (roundData.isNotEmpty) {
      int team1Id = 0;
      int team2Id = 0;
      for (final rd in roundData) {
        if (rd.team.teamNumber == 1) team1Id = rd.teamId;
        if (rd.team.teamNumber == 2) team2Id = rd.teamId;
      }
      return (team1Id: team1Id, team2Id: team2Id);
    }

    // Fallback 2: UpdateScoreResponse keeps API order (0 = Team 01, 1 = Team 02).
    final scoreData = _scoreResponse?.data ?? const [];
    if (scoreData.length >= 2) {
      return (team1Id: scoreData[0].teamId, team2Id: scoreData[1].teamId);
    }

    return (team1Id: 0, team2Id: 0);
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
      drawer: const AppDrawer(),
      body: SafeArea(
        child: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            final stats = context.read<GameCubit>().gameStatisticsResponse;
            final fromStats = stats != null ? _winnerFromStatistics(stats) : null;
            final winnerName = fromStats?.winnerName ?? fallbackWinnerName;
            final winnerScore = fromStats?.winnerScore ?? fallbackWinnerScore;
            final isWinner = fromStats?.isWinner ?? fallbackIsWinner;
            final gameIdFromStats = stats?.data.game.id ?? 0;
            final gameIdToUse = gameIdFromStats != 0 ? gameIdFromStats : _resolveGameId();
            final teamIds = _resolveTeamIdsFromStatsOrFallback(stats);

            return Stack(
              children: [
            // Main card: narrower, taller, and starts right under the drawer icon.
            Positioned(
              // Drawer icon: top = 6.h, height = 36.h  => bottom = 42.h
              // Make the card start exactly at the drawer's bottom.
              top: 75.h,
              left: 70.w,
              right: 70.w,
              // Reduce bottom padding so the whole design goes down a bit.
              bottom: 50.h,
              child: Container(
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
                                style: TextStyles.font32Secondary700Weight,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                winnerName,
                                style: TextStyles.font14Secondary700Weight,
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

            // Drawer icon (top left)
            Positioned(
              top: 6.h,
              left: 6.w,
              child: GameDrawerIcon(),
            ),

            // Next button (bottom right)
            Positioned(
              // Slightly closer to the main card, and aligned under the card's right edge.
              bottom: 24,
              right: 70.w,
              child: GameBottomRightButton(
                text: 'التالي',
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.optionsView,
                    (route) => false,
                    arguments: {
                      // Needed for "+1 category" flow to call /games/add-rounds later.
                      'gameId': gameIdToUse,
                      'team1Id': teamIds.team1Id,
                      'team2Id': teamIds.team2Id,
                      // Preserve names for prefilled GroupsView
                      'team1Name': GlobalStorage.team1Name,
                      'team2Name': GlobalStorage.team2Name,
                    },
                  );
                },
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
