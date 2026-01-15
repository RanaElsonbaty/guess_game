import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_request.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/game_level/presentation/view/widgets/game_level_card.dart';
import 'package:guess_game/core/widgets/subscription_alert_dialog.dart';
import 'package:guess_game/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:guess_game/guess_game.dart';

class GameLevelView extends StatefulWidget {
  const GameLevelView({super.key});

  @override
  State<GameLevelView> createState() => _GameLevelViewState();
}

class GameLevelViewWithProvider extends StatelessWidget {
  const GameLevelViewWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameCubit>(
          create: (context) => getIt<GameCubit>(),
        ),
        BlocProvider<TermsCubit>(
          create: (context) => getIt<TermsCubit>()..loadGameTerms(),
        ),
      ],
      child: const GameLevelView(),
    );
  }
}

class _GameLevelViewState extends State<GameLevelView> {
  String? team1Level;
  String? team2Level;
  String team1Name = 'فريق 01';
  String team2Name = 'فريق 02';
  GameStartResponse? gameStartResponse;

  // تحويل مستوى اللعبة إلى نقاط
  int _convertLevelToPoints(String level) {
    return level == 'سهل' ? 200 : 400;
  }

  @override
  void initState() {
    super.initState();
    // الحصول على أسماء الفرق من الـ arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final Map<String, dynamic>? globalArgs = GuessGame.globalInitialArguments as Map<String, dynamic>?;

      print('🎯 GameLevelView: args = $args');
      print('🎯 GameLevelView: globalArgs = $globalArgs');

      final Map<String, dynamic>? effectiveArgs = args ?? globalArgs;

      if (effectiveArgs != null) {
        setState(() {
          team1Name = effectiveArgs['team1Name'] ?? 'فريق 01';
          team2Name = effectiveArgs['team2Name'] ?? 'فريق 02';
          gameStartResponse = effectiveArgs['gameStartResponse'];
        });

        // حفظ gameStartResponse في GlobalStorage كـ backup
        if (gameStartResponse != null) {
          GlobalStorage.saveGameStartResponse(gameStartResponse);

          // طباعة IDs الخاصة بـ rounds
          print('🎯 GameLevelView: ===== ROUNDS IDs =====');
          for (int i = 0; i < gameStartResponse!.data.rounds.length; i++) {
            final round = gameStartResponse!.data.rounds[i];
            print('🎯 GameLevelView: Round ${i + 1}: id = ${round.id}, round_number = ${round.roundNumber}');
          }
          print('🎯 GameLevelView: Current round index: ${GlobalStorage.currentRoundIndex}');
          print('🎯 GameLevelView: Current round ID: ${GlobalStorage.getCurrentRoundId()}');
          print('🎯 GameLevelView: =====================');
        }
        print('🎯 GameLevelView: team1Name = "$team1Name", team2Name = "$team2Name"');
        print('🎯 GameLevelView: gameStartResponse = $gameStartResponse');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameCubit = context.read<GameCubit>();

    return BlocProvider.value(
      value: gameCubit,
      child: BlocListener<GameCubit, GameState>(
        listener: (context, state) {
          print('🎯 GameLevelView: استلام state: ${state.runtimeType}');
          print('🎯 GameLevelView: gameStartResponse in listener: ${gameStartResponse != null}');
          if (state is PointPlanUpdated) {
            print('✅ تم استلام PointPlanUpdated - عرض dialog التعليمات');
            // عرض dialog التعليمات عند نجاح PATCH
            _showGameInstructionsDialog(context, null);
          } else if (state is PointPlanUpdateError) {
            print('❌ تم استلام PointPlanUpdateError: ${state.message}');
            // عرض رسالة خطأ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PointPlanUpdating) {
            print('🔄 تم استلام PointPlanUpdating - جاري التحديث');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            children: [
              // كاردات الفرق
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.ltr,
                children: [
                  GameLevelCard(
                    teamName: team2Name,
                    teamTitle: 'فريق 02',
                    onLevelSelected: (level) {
                      setState(() {
                        team2Level = level;
                      });
                    },
                  ),
                  const SizedBox(width: 48),
                  GameLevelCard(
                    teamName: team1Name,
                    teamTitle: 'فريق 01',
                    onLevelSelected: (level) {
                      setState(() {
                        team1Level = level;
                      });
                    },
                  ),
                ],
              ),
              const Spacer(),

              // زر البدء
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // التحقق من اختيار المستوى لكلا الفريقين
                    if (team1Level == null || team2Level == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى اختيار مستوى لكلا الفريقين'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // طباعة البيانات الحقيقية
                    print('🎯 الضغط على زر ابدأ');
                    print('🏷️ اسم الفريق الأول: "$team1Name"');
                    print('🏷️ اسم الفريق الثاني: "$team2Name"');
                    print('🏷️ مستوى الفريق الأول: "$team1Level"');
                    print('🏷️ مستوى الفريق الثاني: "$team2Level"');

                    // طباعة فئات الفرق إذا كانت متوفرة
                    if (gameStartResponse!.data.teams.length >= 2) {
                      try {
                        final team1Categories = gameStartResponse!.data.teams[0].roundData.map((rd) => rd.categoryId).toList();
                        final team2Categories = gameStartResponse!.data.teams[1].roundData.map((rd) => rd.categoryId).toList();
                        print('📋 فئات الفريق الأول: $team1Categories');
                        print('📋 فئات الفريق الثاني: $team2Categories');
                        final totalCategories = team1Categories.length + team2Categories.length;
                        print('📊 المجموع الكلي للفئات: $totalCategories فئة');
                      } catch (e) {
                        print('❌ خطأ في طباعة فئات الفرق: $e');
                      }
                    } else {
                      print('⚠️ لا توجد بيانات gameStartResponse متاحة');
                    }

                    print('🚀 بدء اللعب');

                    if (gameStartResponse!.data.teams.length >= 2) {
                      // استخراج البيانات من gameStartResponse
                      final gameId = gameStartResponse!.data.id;
                      final currentRoundIndex = GlobalStorage.currentRoundIndex;

                      // طباعة معلومات تحديث rounds بناءً على رقم round_number
                      print('🎯 GameLevelView: ===== ROUND NUMBER UPDATES =====');
                      for (final round in gameStartResponse!.data.rounds) {
                        final updatedRoundNumber = round.roundNumber + currentRoundIndex;
                        print('🎯 GameLevelView: Round ${round.id}: base round_number ${round.roundNumber} -> updated $updatedRoundNumber');
                      }
                      print('🎯 GameLevelView: ===============================');

                      // الحصول على round_data المناسب للجولة الحالية
                      final baseTeam1RoundDataId = gameStartResponse!.data.teams[0].roundData.length > currentRoundIndex
                          ? gameStartResponse!.data.teams[0].roundData[currentRoundIndex].id : 0;
                      final baseTeam2RoundDataId = gameStartResponse!.data.teams[1].roundData.length > currentRoundIndex
                          ? gameStartResponse!.data.teams[1].roundData[currentRoundIndex].id : 0;

                      // تحديد round_data_id النهائي - استخدم دائما القيمة من GameStartResponse للجولة الحالية
                      final team1RoundDataId = baseTeam1RoundDataId;
                      final team2RoundDataId = baseTeam2RoundDataId;

                      // حفظ القيم المستخدمة للجولة التالية
                      GlobalStorage.updateLastRoundDataIds(team1RoundDataId, team2RoundDataId);

                      // طباعة البيانات المستخدمة والمحدثة
                      print('🎯 GameLevelView: ===== ROUND DATA FOR CURRENT ROUND =====');
                      print('🎯 GameLevelView: currentRoundIndex = $currentRoundIndex');
                      print('🎯 GameLevelView: team1RoundDataId = $team1RoundDataId (from roundData[${currentRoundIndex}])');
                      print('🎯 GameLevelView: team2RoundDataId = $team2RoundDataId (from roundData[${currentRoundIndex}])');
                      print('🎯 GameLevelView: Last used IDs - team1: ${GlobalStorage.lastTeam1RoundDataId}, team2: ${GlobalStorage.lastTeam2RoundDataId}');
                      print('🎯 GameLevelView: Round IDs from GameStartResponse.rounds:');
                      for (int i = 0; i < gameStartResponse!.data.rounds.length; i++) {
                        final round = gameStartResponse!.data.rounds[i];
                        print('🎯 GameLevelView:   Round ${i + 1}: id = ${round.id}, round_number = ${round.roundNumber}');
                      }
                      print('🎯 GameLevelView: Current round data from teams:');
                      for (int i = 0; i < gameStartResponse!.data.teams.length; i++) {
                        final team = gameStartResponse!.data.teams[i];
                        if (team.roundData.length > currentRoundIndex) {
                          final roundData = team.roundData[currentRoundIndex];
                          print('🎯 GameLevelView:   Team ${i + 1} roundData[${currentRoundIndex}]: id = ${roundData.id}');
                        }
                      }
                      print('🎯 GameLevelView: ================================');
                      final team1PointPlan = _convertLevelToPoints(team1Level!);
                      final team2PointPlan = _convertLevelToPoints(team2Level!);

                      // طباعة البيانات المرسلة للـ API
                      print('📤 إرسال PATCH request إلى /games/round/data/update-point-plan');
                      print('📤 game_id: $gameId');
                      print('📤 rounds_data: [');
                      print('📤   {round_data_id: $team1RoundDataId, point_plan: $team1PointPlan},');
                      print('📤   {round_data_id: $team2RoundDataId, point_plan: $team2PointPlan}');
                      print('📤 ]');

                      // إنشاء request لتحديث point_plan
                      final request = UpdatePointPlanRequest(
                        gameId: gameId,
                        roundsData: [
                          RoundDataUpdate(
                            roundDataId: team1RoundDataId,
                            pointPlan: team1PointPlan,
                          ),
                          RoundDataUpdate(
                            roundDataId: team2RoundDataId,
                            pointPlan: team2PointPlan,
                          ),
                        ],
                      );

                      // استدعاء updatePointPlan
                      print('🔄 استدعاء updatePointPlan...');
                      try {
                        gameCubit.updatePointPlan(request);
                        print('✅ تم استدعاء updatePointPlan بنجاح');
                      } catch (e) {
                        print('❌ خطأ في استدعاء updatePointPlan: $e');
                      }
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// 🔸 Main Button Body
                      Container(
                        height: 36,
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.buttonYellow,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'ابدأ',
                          style: TextStyles.font10Secondary700Weight,
                        ),
                      ),

                      /// Right Border
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: AppColors.buttonBorderOrange,
                        ),
                      ),

                      /// Bottom Border
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
          ),
        ),
      ),
    ),
  );
  }

  void _showGameInstructionsDialog(BuildContext context, gameStartResponse) {
    // الحصول على UpdatePointPlanResponse من GameCubit قبل عرض الـ dialog
    final gameCubit = context.read<GameCubit>();
    final termsCubit = context.read<TermsCubit>();
    final updatePointPlanResponse = gameCubit.updatePointPlanResponse;

    // حفظ الـ context الأصلي لاستخدامه في التنقل
    final navigationContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: termsCubit,
          child: BlocBuilder<TermsCubit, TermsState>(
            builder: (context, termsState) {
              final currentTermsCubit = context.read<TermsCubit>();
              return SubscriptionAlertDialog(
                title: 'تعليمات',
                content: currentTermsCubit.formattedTermsText,
                buttonText: 'حسنا',
                onButtonPressed: () async {
                  // إغلاق dialog التعليمات باستخدام dialog context
                  Navigator.of(dialogContext).pop();

                  // انتظار إغلاق الـ dialog
                  await Future.delayed(const Duration(milliseconds: 200));

                  // التحقق من رقم الجولة الحالية
                  final currentRoundIndex = GlobalStorage.currentRoundIndex;
                  final isFirstRound = currentRoundIndex == 0;
                  final shouldSkipToScore = currentRoundIndex > 1; // تخطي للجولات الأحدث من الثانية

                  if (kDebugMode) {
                    print('🎯 GameLevelView: currentRoundIndex: $currentRoundIndex');
                    print('🎯 GameLevelView: isFirstRound: $isFirstRound');
                    print('🎯 GameLevelView: shouldSkipToScore: $shouldSkipToScore');
                  }

                  if (navigationContext.mounted) {
                    if (shouldSkipToScore) {
                      // جولات أحدث من الثانية - انتقل مباشرة إلى ScoreView
                      if (kDebugMode) {
                        print('🎯 GameLevelView: Navigating directly to scoreView (rounds > 1)');
                      }
                      Navigator.of(navigationContext).pushNamed(
                        Routes.scoreView,
                        arguments: {
                          'updatePointPlanResponse': updatePointPlanResponse,
                          'updateScoreResponse': null, // سيتم الحصول عليه من cubit أو GlobalStorage
                          'gameStartResponse': gameStartResponse,
                          'assignWinnerResponse': null, // سيتم الحصول عليه من cubit
                        },
                      );
                    } else {
                      // الجولة الأولى والثانية - انتقل إلى qrcodeView لعرض UpdatePointPlanResponse
                      if (kDebugMode) {
                        print('🎯 GameLevelView: Navigating to qrcodeView (round 0 or 1)');
                      }
                      Navigator.of(navigationContext).pushNamed(
                        Routes.qrcodeView,
                        arguments: {
                          'updatePointPlanResponse': updatePointPlanResponse,
                          'gameStartResponse': gameStartResponse,
                        },
                      );
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }


}