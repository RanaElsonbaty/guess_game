import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/features/game/data/models/assign_winner_response.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_response.dart';
import 'package:guess_game/features/game/data/models/update_score_response.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/folder_team_score_card.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_bottom_right_button.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:guess_game/guess_game.dart';

class ScoreView extends StatefulWidget {
  const ScoreView({super.key});

  @override
  State<ScoreView> createState() => _ScoreViewState();
}

class _ScoreViewState extends State<ScoreView> {
  UpdatePointPlanResponse? _pointPlanResponse;
  UpdateScoreResponse? _scoreResponse;
  AssignWinnerResponse? _assignWinnerResponse;
  GameStartResponse? _gameStartResponse;
  bool _didReadArgs = false;
  bool _isLastRound = false;
  bool _isReplay = false; // Track if this is a repeat game flow

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
      print('🎯 ScoreView: args = $args');
      print('🎯 ScoreView: globalArgs = $globalArgs');
    }

    final effectiveArgs = args ?? globalArgs;
    final p = effectiveArgs?['updatePointPlanResponse'];
    final s = effectiveArgs?['updateScoreResponse'];
    final a = effectiveArgs?['assignWinnerResponse'];
    final g = effectiveArgs?['gameStartResponse'];
    _isReplay = effectiveArgs?['isReplay'] ?? false; // Get replay flag
    if (p is UpdatePointPlanResponse) {
      setState(() => _pointPlanResponse = p);
    }
    if (s is UpdateScoreResponse) {
      setState(() => _scoreResponse = s);
    }
    if (a is AssignWinnerResponse) {
      setState(() => _assignWinnerResponse = a);
    }
    if (g is GameStartResponse) {
      setState(() => _gameStartResponse = g);
    }

    // Calculate if this is the last round
    _calculateIfLastRound();

    if (kDebugMode) {
      print('🎯 ScoreView: didChangeDependencies completed');
      print('🎯 ScoreView: _isLastRound: $_isLastRound');
      print('🎯 ScoreView: Current round ID: ${GlobalStorage.getCurrentRoundId()}');
      print('🎯 ScoreView: Next round number: ${GlobalStorage.getNextRoundNumber()}');

      // طباعة round id للجولة التالية من rounds array
      if (_gameStartResponse != null) {
        final nextRoundIndex = GlobalStorage.currentRoundIndex + 1;
        if (nextRoundIndex < _gameStartResponse!.data.rounds.length) {
          final nextRound = _gameStartResponse!.data.rounds[nextRoundIndex];
          print('🎯 ScoreView: Round ID للجولة التالية:');
          print('🎯 ScoreView:   Round ${nextRoundIndex + 1}: id = ${nextRound.id} (round_number: ${nextRound.roundNumber})');
        } else {
          print('🎯 ScoreView: انتهت جميع الجولات');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamScores = _extractTeamScores();
    final team01Score = teamScores['team01'] ?? 0;
    final team02Score = teamScores['team02'] ?? 0;

    // Match QrcodeView sizing/spacing.
    const double cardW = 235;
    const double cardH = 280;
    const double gapW = 110;
    final double contentW = MediaQuery.sizeOf(context).width - (48.w); // padding left+right = 24.w * 2
    final double rowW = (cardW * 2 + gapW).w;
    final double rightAlignedToRow = 24.w + math.max(0, (contentW - rowW) / 2);

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

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content (center), with reserved top/bottom space like GameWinnerView
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: 52.h, bottom: 70.h, left: 24.w, right: 24.w),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.ltr,
                    children: [
                      FolderTeamScoreCard(
                        teamTitle: 'نقاط فريق ${GlobalStorage.team2Name.isNotEmpty ? GlobalStorage.team2Name : '02'}',
                        score: team02Score,
                        isWinner: winnerTeam == 2,
                        isLoser: winnerTeam == 1,
                        width: cardW,
                        height: cardH,
                        scoreBoxSize: 85,
                      ),
                      SizedBox(width: gapW.w),
                      FolderTeamScoreCard(
                        teamTitle: 'نقاط فريق ${GlobalStorage.team1Name.isNotEmpty ? GlobalStorage.team1Name : '01'}',
                        score: team01Score,
                        isWinner: winnerTeam == 1,
                        isLoser: winnerTeam == 2,
                        width: cardW,
                        height: cardH,
                        scoreBoxSize: 85,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6.h,
              left: 6.w,
              child: Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      width: 60.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppIcons.list,
                        height: 18.h,
                        width: 26.w,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next button aligned to the right bottom of the screen
            Positioned(
              bottom: 24,
              right: 24.w,
              child: GameBottomRightButton(
                text: 'التالي',
                onTap: () {
                  if (_isLastRound) {
                    Navigator.of(context).pushNamed(
                      Routes.gameWinnerView,
                      arguments: {
                        'updatePointPlanResponse': _pointPlanResponse,
                        'updateScoreResponse': _scoreResponse,
                        'assignWinnerResponse': _assignWinnerResponse,
                        'gameStartResponse': _gameStartResponse,
                        'isReplay': _isReplay, // Pass replay flag to GameWinnerView
                      },
                    );
                  } else {
                    GlobalStorage.moveToNextRound();
                    Navigator.of(context).pushNamed(
                      Routes.gameLevel,
                      arguments: {
                        'team1Name': GlobalStorage.team1Name.isNotEmpty ? GlobalStorage.team1Name : 'فريق 01',
                        'team2Name': GlobalStorage.team2Name.isNotEmpty ? GlobalStorage.team2Name : 'فريق 02',
                        'gameStartResponse': _gameStartResponse,
                        'isReplay': _isReplay, // Pass replay flag to next round
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateIfLastRound() {
    if (_gameStartResponse == null) {
      _isLastRound = false;
      return;
    }

    final rounds = _gameStartResponse!.data.rounds;
    final totalRounds = rounds.length;

    // Get current round index from GlobalStorage
    final currentRoundIndex = GlobalStorage.currentRoundIndex;

    // Check if this is the last round
    _isLastRound = (currentRoundIndex + 1 >= totalRounds);

    if (kDebugMode) {
      print('🎯 ScoreView: totalRounds: $totalRounds');
      print('🎯 ScoreView: currentRoundIndex: $currentRoundIndex');
      print('🎯 ScoreView: isLastRound: $_isLastRound');
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
}
