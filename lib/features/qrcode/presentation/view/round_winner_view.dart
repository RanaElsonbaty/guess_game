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
import 'package:guess_game/features/game/data/models/assign_winner_request.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_score_response.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/yellow_pill_button.dart';
import 'package:guess_game/guess_game.dart';

class RoundWinnerView extends StatefulWidget {
  const RoundWinnerView({super.key});

  @override
  State<RoundWinnerView> createState() => _RoundWinnerViewState();
}

class _RoundWinnerViewState extends State<RoundWinnerView> {
  UpdateScoreResponse? _updateScoreResponse;
  GameStartResponse? _gameStartResponse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // First priority: get from arguments (passed from previous screens)
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Map<String, dynamic>? globalArgs =
        GuessGame.globalInitialArguments as Map<String, dynamic>?;

    final effectiveArgs = args ?? globalArgs;
    _updateScoreResponse = effectiveArgs?['updateScoreResponse'];
    _gameStartResponse = effectiveArgs?['gameStartResponse'];

    if (kDebugMode) {
      print('🎯 RoundWinnerView: From arguments - updateScoreResponse: ${_updateScoreResponse != null}');
      print('🎯 RoundWinnerView: From arguments - gameStartResponse: ${_gameStartResponse != null}');
      print('🎯 RoundWinnerView: args keys: ${args?.keys.toList()}');
      print('🎯 RoundWinnerView: globalArgs keys: ${globalArgs?.keys.toList()}');
      print('🎯 RoundWinnerView: data loaded successfully');
    }

    // Fallback: get from cubit if not available in arguments
    final cubit = context.read<GameCubit>();
    _updateScoreResponse ??= cubit.updateScoreResponse;
    _gameStartResponse ??= cubit.gameStartResponse;

    // Final fallback: get from GlobalStorage
    _gameStartResponse ??= GlobalStorage.gameStartResponse;


    if (kDebugMode) {
      print('🎯 RoundWinnerView: After cubit fallback - updateScoreResponse: ${_updateScoreResponse != null}');
      print('🎯 RoundWinnerView: After cubit fallback - gameStartResponse: ${_gameStartResponse != null}');
      print('🎯 RoundWinnerView: From GlobalStorage - gameStartResponse: ${GlobalStorage.gameStartResponse != null}');
    }
  }


  int? _getTeamId(int teamIndex) {
    // teamIndex: 0 = team1, 1 = team2
    if (_updateScoreResponse == null || _updateScoreResponse!.data.length <= teamIndex) {
      return null;
    }
    return _updateScoreResponse!.data[teamIndex].teamId;
  }

  Future<void> _assignWinner(int teamIndex) async {
    if (kDebugMode) {
      print('🎯 RoundWinnerView: _assignWinner called with teamIndex = $teamIndex');
      print('🎯 RoundWinnerView: _updateScoreResponse = ${_updateScoreResponse != null}');
      print('🎯 RoundWinnerView: _gameStartResponse = ${_gameStartResponse != null}');
    }

    if (_updateScoreResponse == null || _updateScoreResponse!.data.isEmpty) {
      if (kDebugMode) {
        print('🎯 RoundWinnerView: No update score response data');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد بيانات متاحة لتعيين الفائز')),
      );
      return;
    }

    if (_gameStartResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد بيانات اللعبة المتاحة')),
      );
      return;
    }

    final teamId = _getTeamId(teamIndex);
    if (teamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن تحديد معرف الفريق')),
      );
      return;
    }

    // Get round ID for the round that just finished
    final currentRoundIndex = GlobalStorage.currentRoundIndex;
    final roundIndexForWinner = currentRoundIndex; // Current round that just finished
    final gameId = _gameStartResponse!.data.id;

    int roundId = 0;
    if (_gameStartResponse!.data.rounds.length > roundIndexForWinner && roundIndexForWinner >= 0) {
      roundId = _gameStartResponse!.data.rounds[roundIndexForWinner].id;
    }

    if (kDebugMode) {
      print('🎯 RoundWinnerView: ===== ASSIGN WINNER REQUEST =====');
      print('🎯 RoundWinnerView: Base round ID from GlobalStorage: ${GlobalStorage.getCurrentRoundId()}');
      print('🎯 RoundWinnerView: Current round index: $currentRoundIndex');
      print('🎯 RoundWinnerView: Round index for winner: $roundIndexForWinner');
      print('🎯 RoundWinnerView: Final round ID: $roundId');
      print('🎯 RoundWinnerView: Game ID: $gameId');
    }

    if (roundId == 0) {
      if (kDebugMode) {
        print('🎯 RoundWinnerView: Invalid round ID - no round found at index $roundIndexForWinner');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في تحديد رقم الجولة')),
      );
      return;
    }

    final request = AssignWinnerRequest(
      gameId: _gameStartResponse!.data.id,
      roundId: roundId,
      teamId: teamId,
    );

    if (kDebugMode) {
      print('🎯 RoundWinnerView: AssignWinnerRequest JSON:');
      print(request.toJson());
      print('🎯 RoundWinnerView: AssignWinnerRequest details:');
      print('  - gameId: $gameId');
      print('  - roundId: $roundId (from round index $roundIndexForWinner)');
      print('  - teamId: $teamId');
      print('🎯 RoundWinnerView: ==============================');
    }

    final cubit = context.read<GameCubit>();
    final response = await cubit.assignWinner(request);

    if (kDebugMode) {
      print('🎯 RoundWinnerView: AssignWinnerResponse JSON:');
      print(response?.toJson() ?? 'null');
      if (response != null) {
        print('🎯 RoundWinnerView: AssignWinnerResponse details:');
        print('  - success: ${response.success}');
        print('  - message: ${response.message}');
        print('  - code: ${response.code}');
        print('  - gameId: ${response.data.gameId}');
        print('  - roundId: ${response.data.roundId}');
        print('  - teams count: ${response.data.roundData.length}');
        for (var i = 0; i < response.data.roundData.length; i++) {
          final roundData = response.data.roundData[i];
          print('    Team ${i + 1}: ${roundData.team.name} (${roundData.team.totalPoints} points) - Winner: ${roundData.team.isWinner}');
        }
      }
    }

    if (response != null && mounted) {
      // Navigate to ScoreView immediately after assigning winner
      Navigator.of(context).pushNamed(
        Routes.scoreView,
        arguments: {
          'assignWinnerResponse': response,
          'updateScoreResponse': _updateScoreResponse,
          'gameStartResponse': _gameStartResponse,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🎯 RoundWinnerView: build() called');
      print('🎯 RoundWinnerView: _updateScoreResponse: ${_updateScoreResponse != null}');
      print('🎯 RoundWinnerView: _gameStartResponse: ${_gameStartResponse != null}');
    }

    final team1Name = GlobalStorage.team1Name.isNotEmpty ? GlobalStorage.team1Name : 'الفريق الأول';
    final team2Name = GlobalStorage.team2Name.isNotEmpty ? GlobalStorage.team2Name : 'الفريق الثاني';

    return BlocListener<GameCubit, GameState>(
      listener: (context, state) {
        // Handle error state
        if (state is WinnerAssignError) {
          if (kDebugMode) {
            print('🎯 RoundWinnerView: WinnerAssignError state received: ${state.message}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          if (kDebugMode) {
            print('🎯 RoundWinnerView: Building main UI');
          }

          // Return main UI (no loading indicator)
          return Scaffold(
          backgroundColor: Colors.white,
          drawer: const Drawer(),
          body: SafeArea(
            child: Stack(
              children: [
                // Match QrcodeView positioning: content sits under the drawer icon with fixed top/bottom spacing.
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(top: 70.h, bottom: 52.h, left: 0, right: 24.w),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        // Use the same visual width as the QrcodeView cards row (2 cards + gap).
                        width: (255 * 2 + 92).w,
                        height: 280.h,
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.white),
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
                              /// Content container
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
                                      SizedBox(height: 30.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          YellowPillButton(
                                            width: 90,
                                            height: 38,
                                            onTap: () => _assignWinner(0),
                                            child: Text(
                                              team1Name,
                                              style: TextStyles.font20Secondary700Weight,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          YellowPillButton(
                                            width: 90,
                                            height: 38,
                                            onTap: () => _assignWinner(1),
                                            child: Text(
                                              team2Name,
                                              style: TextStyles.font20Secondary700Weight,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          YellowPillButton(
                                            width: 90,
                                            height: 38,
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                Routes.scoreView,
                                                arguments: {
                                                  'assignWinnerResponse': null,
                                                  'updateScoreResponse': _updateScoreResponse,
                                                  'gameStartResponse': _gameStartResponse,
                                                },
                                              );
                                            },
                                            child: Text(
                                              'تعادل',
                                              style: TextStyles.font20Secondary700Weight,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
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
                ),

                // Drawer icon (same as QrcodeView)
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
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}

