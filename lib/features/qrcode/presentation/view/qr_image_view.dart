import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_response.dart';
import 'package:guess_game/features/game/data/models/update_score_response.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/folder_team_image_card.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/small_yellow_corner_button.dart';
import 'package:guess_game/guess_game.dart';

class QrImageView extends StatefulWidget {
  const QrImageView({super.key});

  @override
  State<QrImageView> createState() => _QrImageViewState();
}

class _QrImageViewState extends State<QrImageView> {
  UpdatePointPlanResponse? _pointPlanResponse;
  UpdateScoreResponse? _scoreResponse;
  GameStartResponse? _gameStartResponse;
  bool _didReadArgs = false;

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
      print('🎯 QrImageView: args = $args');
      print('🎯 QrImageView: globalArgs = $globalArgs');
    }

    // First priority: read from args directly
    if (args != null) {
      final p = args['updatePointPlanResponse'];
      final s = args['updateScoreResponse'];
      final g = args['gameStartResponse'];
      if (p is UpdatePointPlanResponse) {
        setState(() => _pointPlanResponse = p);
      }
      if (s is UpdateScoreResponse) {
        setState(() => _scoreResponse = s);
      }
      if (g is GameStartResponse) {
        setState(() => _gameStartResponse = g);
      }
    }

    // Fallback: read from globalArgs if not found in args
    if (_pointPlanResponse == null && globalArgs != null) {
      final p = globalArgs['updatePointPlanResponse'];
      if (p is UpdatePointPlanResponse) {
        setState(() => _pointPlanResponse = p);
      }
    }

    if (_scoreResponse == null && globalArgs != null) {
      final s = globalArgs['updateScoreResponse'];
      if (s is UpdateScoreResponse) {
        setState(() => _scoreResponse = s);
      }
    }

    if (_gameStartResponse == null && globalArgs != null) {
      final g = globalArgs['gameStartResponse'];
      if (g is GameStartResponse) {
        setState(() => _gameStartResponse = g);
      }
    }

    if (kDebugMode) {
      print('🎯 QrImageView: didChangeDependencies finished');
      print('🎯 QrImageView: _scoreResponse: ${_scoreResponse != null}');
      print('🎯 QrImageView: _gameStartResponse: ${_gameStartResponse != null}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _extractTeamImages();
    final team01Image = images['team01'] ?? '';
    final team02Image = images['team02'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const Drawer(),
      body: SafeArea(
        child: Stack(
          children: [
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
                        FolderTeamImageCard(
                          teamTitle: 'الفريق 02',
                          imageUrl: team02Image,
                          width: 237,
                          height: 240,
                          imageBoxSize: 145,
                        ),
                        SizedBox(width: 48.w),
                        FolderTeamImageCard(
                          teamTitle: 'الفريق 01',
                          imageUrl: team01Image,
                          width: 237,
                          height: 240,
                          imageBoxSize: 145,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SmallYellowCornerButton(
                        text: 'التالي',
                        onTap: () {
                          // الانتقال إلى صفحة تحديد الفائز
                          // تمرير البيانات المطلوبة
                          if (kDebugMode) {
                            print('🎯 QrImageView: Navigating to RoundWinnerView');
                            print('🎯 QrImageView: _scoreResponse: ${_scoreResponse != null}');
                            print('🎯 QrImageView: _gameStartResponse: ${_gameStartResponse != null}');
                          }
                          Navigator.of(context).pushNamed(
                            Routes.roundWinnerView,
                            arguments: {
                              'updateScoreResponse': _scoreResponse,
                              'gameStartResponse': _gameStartResponse,
                            },
                          );
                        },
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
          ],
        ),
      ),
    );
  }

  Map<String, String> _extractTeamImages() {
    // Preferred: update-score response (it contains image_path per team in data[]).
    final scoreData = _scoreResponse?.data;
    if (scoreData != null && scoreData.isNotEmpty) {
      // Keep API order: first item = Team 01, second item = Team 02.
      final team01 = scoreData.isNotEmpty ? scoreData[0] : null;
      final team02 = scoreData.length > 1 ? scoreData[1] : null;
      return {
        'team01': team01?.imagePath ?? '',
        'team02': team02?.imagePath ?? '',
      };
    }

    // Fallback: update-point-plan response (it contains image_path per team in round_data).
    final roundData = _pointPlanResponse?.data.roundData;
    if (roundData != null && roundData.isNotEmpty) {
      // Important: keep API order to avoid swapping Team 01/02 when teamId is not a simple 1/2.
      // Convention in the app: first item = Team 01, second item = Team 02.
      final team01 = roundData.isNotEmpty ? roundData[0] : null;
      final team02 = roundData.length > 1 ? roundData[1] : null;
      return {
        'team01': team01?.imagePath ?? '',
        'team02': team02?.imagePath ?? '',
      };
    }
    return const {'team01': '', 'team02': ''};
  }
}


