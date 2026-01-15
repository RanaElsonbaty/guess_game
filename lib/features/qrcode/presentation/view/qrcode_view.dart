import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_response.dart';
import 'package:guess_game/features/game/data/models/update_score_request.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/folder_team_qr_card.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/small_yellow_corner_button.dart';
import 'package:guess_game/guess_game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QrcodeView extends StatefulWidget {
  const QrcodeView({super.key});

  @override
  State<QrcodeView> createState() => _QrcodeViewState();
}

class QrcodeViewWithProvider extends StatelessWidget {
  const QrcodeViewWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // GameCubit is already provided at app level, so we can use it directly
    return const QrcodeView();
  }
}

class _QrcodeViewState extends State<QrcodeView> {
  UpdatePointPlanResponse? updatePointPlanResponse;
  GameStartResponse? gameStartResponse;
  bool _didReadArgs = false;
  bool _isSubmitting = false;

  int _team01Questions = 0;
  int _team01Answers = 0;
  int _team02Questions = 0;
  int _team02Answers = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;

    // Read the arguments once (RouteSettings is now preserved by AppRoutes).
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Map<String, dynamic>? globalArgs =
        GuessGame.globalInitialArguments as Map<String, dynamic>?;

    if (kDebugMode) {
      print('🎯 QrcodeView: args = $args');
      print('🎯 QrcodeView: globalArgs = $globalArgs');
    }

    // First priority: read from args directly
    if (args != null) {
      final response = args['updatePointPlanResponse'];
      if (response is UpdatePointPlanResponse) {
        setState(() => updatePointPlanResponse = response);
        if (kDebugMode) {
          // Debug log for troubleshooting payload issues (do not enable in release).
          print('🧾 updatePointPlanResponse JSON: ${jsonEncode(response.toJson())}');
        }
      }

      final gameResponse = args['gameStartResponse'];
      if (gameResponse is GameStartResponse) {
        setState(() => gameStartResponse = gameResponse);
        if (kDebugMode) {
          print('🎯 QrcodeView: gameStartResponse received from args');
        }
      }
    }

    // Fallback: read from globalArgs if not found in args
    if (updatePointPlanResponse == null && globalArgs != null) {
      final response = globalArgs['updatePointPlanResponse'];
      if (response is UpdatePointPlanResponse) {
        setState(() => updatePointPlanResponse = response);
      }
    }

    if (gameStartResponse == null && globalArgs != null) {
      final gameResponse = globalArgs['gameStartResponse'];
      if (gameResponse is GameStartResponse) {
        setState(() => gameStartResponse = gameResponse);
        if (kDebugMode) {
          print('🎯 QrcodeView: gameStartResponse received from globalArgs');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundDataList = updatePointPlanResponse?.data.roundData ?? const <UpdatedRoundData>[];
    // Keep API order: first item = Team 01, second item = Team 02.
    final orderedUniqueTeams = _pickTwoTeamsRoundData(roundDataList).toList();
    final team01RoundData = orderedUniqueTeams.isNotEmpty ? orderedUniqueTeams[0] : null;
    final team02RoundData = orderedUniqueTeams.length > 1 ? orderedUniqueTeams[1] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const Drawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Content (cards + next button) centered like the reference.
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 52.h, left: 24.w, right: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.ltr,
                      children: [
                        FolderTeamQrCard(
                          teamTitle: 'الفريق 02',
                          qrCode: team02RoundData?.qrCode ?? '',
                          questionsCount: team02RoundData?.questionNumber,
                          answersCount: team02RoundData?.answerNumber,
                          maxQuestions: team02RoundData?.maxQuestions ?? 20,
                          maxAnswers: team02RoundData?.maxAnswers ?? 2,
                          width: 237,
                          height: 240,
                          qrBoxSize: 160,
                          canUpdateQuestions: team02RoundData?.canUpdateQuestions ?? true,
                          canUpdateAnswers: team02RoundData?.canUpdateAnswers ?? true,
                          onScoreChanged: (q, a) {
                            _team02Questions = q;
                            _team02Answers = a;
                          },
                        ),
                        SizedBox(width: 48.w),
                        FolderTeamQrCard(
                          teamTitle: 'الفريق 01',
                          qrCode: team01RoundData?.qrCode ?? '',
                          questionsCount: team01RoundData?.questionNumber,
                          answersCount: team01RoundData?.answerNumber,
                          maxQuestions: team01RoundData?.maxQuestions ?? 20,
                          maxAnswers: team01RoundData?.maxAnswers ?? 2,
                          width: 237,
                          height: 240,
                          qrBoxSize: 160,
                          canUpdateQuestions: team01RoundData?.canUpdateQuestions ?? true,
                          canUpdateAnswers: team01RoundData?.canUpdateAnswers ?? true,
                          onScoreChanged: (q, a) {
                            _team01Questions = q;
                            _team01Answers = a;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SmallYellowCornerButton(
                        text: 'التالي',
                        onTap: _isSubmitting
                            ? null
                            : () => _submitScoreAndNavigate(
                                  context,
                                  team01RoundData: team01RoundData,
                                  team02RoundData: team02RoundData,
                                ),
                      ),
                    ),
                  ],
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
                      width: 64.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(AppIcons.list,
                      height: 24.h,width: 36.w,),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Picks one roundData item per team (by teamId), keeping the API order,
  /// and returns at most two teams for the UI cards.
  List<UpdatedRoundData> _pickTwoTeamsRoundData(List<UpdatedRoundData> list) {
    final seen = <int>{};
    final result = <UpdatedRoundData>[];
    for (final item in list) {
      if (item.qrCode.isEmpty) continue;
      if (seen.add(item.teamId)) {
        result.add(item);
        if (result.length == 2) break;
      }
    }
    // If QR codes are missing, fall back to first two items (even if empty) to keep layout stable.
    if (result.isEmpty && list.isNotEmpty) {
      return list.take(2).toList();
    }
    return result;
  }

  Future<void> _submitScoreAndNavigate(
    BuildContext context, {
    required UpdatedRoundData? team01RoundData,
    required UpdatedRoundData? team02RoundData,
  }) async {
    final updateResp = updatePointPlanResponse;
    if (updateResp == null || team01RoundData == null || team02RoundData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات اللعبة غير مكتملة')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final gameCubit = context.read<GameCubit>();
      final request = UpdateScoreRequest(
        gameId: updateResp.data.gameId,
        roundsData: [
          RoundScoreUpdate(
            roundDataId: team01RoundData.id,
            questionsCount: _team01Questions,
            answersCount: _team01Answers,
          ),
          RoundScoreUpdate(
            roundDataId: team02RoundData.id,
            questionsCount: _team02Questions,
            answersCount: _team02Answers,
          ),
        ],
      );

      final scoreResponse = await gameCubit.updateScore(request);
      if (!mounted) return;

      if (scoreResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحديث السكور')),
        );
        return;
      }

      // Store values locally
      await GlobalStorage.saveGameScore(
        t1Questions: _team01Questions,
        t1Answers: _team01Answers,
        t2Questions: _team02Questions,
        t2Answers: _team02Answers,
      );

      if (kDebugMode) {
        print('🎯 QrcodeView: Navigating to QrImageView');
        print('🎯 QrcodeView: scoreResponse: ${scoreResponse != null}');
        print('🎯 QrcodeView: updateResp: ${updateResp != null}');
        print('🎯 QrcodeView: gameStartResponse: ${gameStartResponse != null}');
      }

      Navigator.of(context).pushNamed(
        Routes.qrimageView,
        arguments: {
          'updateScoreResponse': scoreResponse,
          'updatePointPlanResponse': updateResp,
          'gameStartResponse': gameStartResponse,
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
