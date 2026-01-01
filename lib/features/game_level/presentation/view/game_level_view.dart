import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_request.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/game_level/presentation/view/widgets/game_level_card.dart';
import 'package:guess_game/core/widgets/subscription_alert_dialog.dart';
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
    return BlocProvider<GameCubit>(
      create: (context) => getIt<GameCubit>(),
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
                      final team1RoundDataId = gameStartResponse!.data.teams[0].roundData.isNotEmpty ? gameStartResponse!.data.teams[0].roundData[0].id : 0;
                      final team2RoundDataId = gameStartResponse!.data.teams[1].roundData.isNotEmpty ? gameStartResponse!.data.teams[1].roundData[0].id : 0;
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
    final updatePointPlanResponse = gameCubit.updatePointPlanResponse;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return SubscriptionAlertDialog(
          title: 'تعليمات',
          content: 'شروط اللعبه هتتكتب هنا و هيبان فيها كل الشروط اللازمه للعبه',
          buttonText: 'حسنا',
          onButtonPressed: () async {
            // إغلاق dialog التعليمات باستخدام dialog context
            Navigator.of(dialogContext).pop();

            // انتظار إغلاق الـ dialog
            await Future.delayed(const Duration(milliseconds: 200));

            // الانتقال إلى صفحة QR codes باستخدام الـ context الخارجي
            if (context.mounted) {
              Navigator.of(context).pushNamed(
                Routes.qrcodeView,
                arguments: {
                  'updatePointPlanResponse': updatePointPlanResponse,
                },
              );
            }
          },
        );
      },
    );
  }


}