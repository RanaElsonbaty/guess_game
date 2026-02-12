import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_request.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/game_level/presentation/view/widgets/game_level_card.dart';
import 'package:guess_game/core/widgets/subscription_alert_dialog.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:guess_game/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:guess_game/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_bottom_right_button.dart';
import 'package:guess_game/core/helper_functions/toast_helper.dart';
import 'package:guess_game/features/levels/presentation/cubit/categories_cubit.dart';
import 'package:guess_game/features/levels/presentation/data/models/category.dart' as category_model;
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
        BlocProvider<NotificationCubit>(
          create: (context) => getIt<NotificationCubit>(),
        ),
        BlocProvider<CategoriesCubit>(
          create: (context) => getIt<CategoriesCubit>(),
        ),
      ],
      child: const GameLevelView(),
    );
  }
}

class _GameLevelViewState extends State<GameLevelView> {
  bool _hasShownInstructionsDialog = false;
  bool _isReplay = false; // Flag to track if this is a repeat game flow
  
  String _getTermsText(BuildContext context) {
    final termsCubit = context.read<TermsCubit>();
    final termsText = termsCubit.formattedTermsText;

    print('📋 Terms status - isLoaded: ${termsCubit.isLoaded}, isLoading: ${termsCubit.isLoading}, hasError: ${termsCubit.hasError}');
    print('📋 Terms text length: ${termsText.length}');

    // If terms text is empty, provide fallback
    if (termsText.isEmpty) {
      print('📋 Using fallback terms text');
      return 'كل واحد بيختار الفئات وبيحدد مستوي الصعوبه\n\nلو اخترت صعب هتكسب 400 نقطه ولي قدامك هيخسر 100 نقطه وليك 30 سؤال و 3 اجابات\n\nلو اخترت سهل هتكسب 200 ولي قادمك هيخسر 50 وليك 20 سؤال و اجابتين';
    }

    print('📋 Using loaded terms text');
    return termsText;
  }
  String? team1Level;
  String? team2Level;
  String team1Name = 'فريق 01';
  String team2Name = 'فريق 02';
  GameStartResponse? gameStartResponse;

  // تحويل مستوى اللعبة إلى نقاط
  int _convertLevelToPoints(String level) {
    return level == 'سهل' ? 200 : 400;
  }

  // الحصول على صورة الفئة الحالية لفريق معين
  String? _getCurrentCategoryImageForTeam(int teamIndex) {
    if (gameStartResponse == null) return null;
    if (gameStartResponse!.data.teams.length <= teamIndex) return null;

    final team = gameStartResponse!.data.teams[teamIndex];
    final currentRoundIndex = GlobalStorage.currentRoundIndex;

    // التحقق من أن currentRoundIndex صحيح
    if (currentRoundIndex < 0 || currentRoundIndex >= team.roundData.length) {
      return null;
    }

    final categoryId = team.roundData[currentRoundIndex].categoryId;

    // الحصول على الفئة من CategoriesCubit
    final categoriesCubit = context.read<CategoriesCubit>();
    final category = categoriesCubit.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => category_model.Category(
        id: 0,
        name: '',
        description: '',
        image: '',
        status: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return category.id != 0 ? category.image : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🎯 GameLevelView: didChangeDependencies - دخول الدالة');
    print('🎯 GameLevelView: currentRoundIndex الحالي = ${GlobalStorage.currentRoundIndex}');
    // تحديث currentRoundIndex عند العودة من صفحات أخرى
    if (gameStartResponse != null) {
      // التأكد من أن currentRoundIndex لا يتجاوز عدد الجولات المتاحة
      if (GlobalStorage.currentRoundIndex >= gameStartResponse!.data.rounds.length) {
        GlobalStorage.currentRoundIndex = gameStartResponse!.data.rounds.length - 1;
      }

      print('🎯 GameLevelView: didChangeDependencies - currentRoundIndex: ${GlobalStorage.currentRoundIndex}');

      // طباعة round id للجولة التالية من rounds array (الدور عليهم)
      if (gameStartResponse != null) {
        final nextRoundIndex = GlobalStorage.currentRoundIndex + 1;
        if (nextRoundIndex < gameStartResponse!.data.rounds.length) {
          final nextRound = gameStartResponse!.data.rounds[nextRoundIndex];
          print('🎯 GameLevelView: الدور عليهم - Round ID للجولة التالية:');
          print('🎯 GameLevelView:   Round ${nextRoundIndex + 1}: id = ${nextRound.id} (round_number: ${nextRound.roundNumber})');
        } else {
          print('🎯 GameLevelView: الدور عليهم - انتهت جميع الجولات');
        }
      }
    }
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
          _isReplay = effectiveArgs['isReplay'] ?? false; // Get replay flag
        });

        // حفظ gameStartResponse في GlobalStorage كـ backup
        if (gameStartResponse != null) {
          GlobalStorage.updateGameStartResponse(gameStartResponse);

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
        
        // عرض dialog التعليمات فوراً إذا كان gameStartResponse متوفر
        if (gameStartResponse != null && !_hasShownInstructionsDialog) {
          _hasShownInstructionsDialog = true;
          // انتظر قليلاً للتأكد من اكتمال بناء الواجهة
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showGameInstructionsDialog(context, gameStartResponse);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameCubit = context.read<GameCubit>();

    return BlocListener<TermsCubit, TermsState>(
      listener: (context, termsState) {
        // عرض dialog التعليمات فوراً (مرة واحدة فقط) عندما يكون gameStartResponse متوفر
        if (!_hasShownInstructionsDialog && gameStartResponse != null) {
          _hasShownInstructionsDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showGameInstructionsDialog(context, gameStartResponse);
            }
          });
        }
      },
      child: BlocListener<GameCubit, GameState>(
        listener: (context, state) {
          print('🎯 GameLevelView: استلام state: ${state.runtimeType}');
          print('🎯 GameLevelView: gameStartResponse in listener: ${gameStartResponse != null}');
          if (state is PointPlanUpdated) {
            print('✅ تم استلام PointPlanUpdated');
            // لا نعرض dialog التعليمات هنا لأنها تم عرضها عند فتح الصفحة
            // فقط ننتقل مباشرة إلى qrcodeView
            final updatePointPlanResponse = gameCubit.updatePointPlanResponse;
            final currentRoundIndex = GlobalStorage.currentRoundIndex;
            final totalRounds = gameStartResponse?.data.rounds.length ?? 0;
            final shouldSkipToScore = (currentRoundIndex + 1) >= totalRounds;

            if (kDebugMode) {
              print('🎯 GameLevelView: currentRoundIndex: $currentRoundIndex');
              print('🎯 GameLevelView: shouldSkipToScore: $shouldSkipToScore');
            }

            if (mounted) {
              Navigator.of(context).pushNamed(
                Routes.qrcodeView,
                arguments: {
                  'updatePointPlanResponse': updatePointPlanResponse,
                  'gameStartResponse': gameStartResponse,
                  'isReplay': _isReplay, // Pass replay flag to QrcodeView
                },
              );
            }
          } else if (state is PointPlanUpdateError) {
            print('❌ API Error: ${state.message}');
          } else if (state is PointPlanUpdating) {
            print('🔄 تم استلام PointPlanUpdating - جاري التحديث');
          }
        },
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, categoriesState) {
          // التأكد من تحميل الفئات
          if (categoriesState is CategoriesInitial && gameStartResponse != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final categoriesCubit = context.read<CategoriesCubit>();
              if (!categoriesCubit.isLoaded) {
                categoriesCubit.loadCategories();
              }
            });
          }

          return SafeArea(
            child: Scaffold(
            backgroundColor: Colors.white,
            drawer: const AppDrawer(),
            body: Stack(
              children: [
                // Compute the same bottom-right alignment as QrcodeView (under the row's right edge).
                // Kept here (inside build) to avoid nested Builders and keep braces simple.
                // Match QrcodeView positioning: cards aligned high, bottom button aligned to row.
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(top: 52.h, bottom: 70.h, left: 24.w, right: 24.w),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: TextDirection.ltr,
                        children: [
                          GameLevelCard(
                            teamName: team2Name,
                            teamTitle: 'فريق $team2Name', // إضافة كلمة "الفريق" قبل الاسم
                            imageUrl: _getCurrentCategoryImageForTeam(1), // Team 2 (index 1)
                            onLevelSelected: (level) {
                              setState(() {
                                team2Level = level;
                              });
                            },
                          ),
                          SizedBox(width: 92.w),
                          GameLevelCard(
                            teamName: team1Name,
                            teamTitle: 'فريق $team1Name', // إضافة كلمة "الفريق" قبل الاسم
                            imageUrl: _getCurrentCategoryImageForTeam(0), // Team 1 (index 0)
                            onLevelSelected: (level) {
                              setState(() {
                                team1Level = level;
                              });
                            },
                          ),
                        ],
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

                // Start button aligned under the cards row (same as QrcodeView)
                Positioned(
                  bottom: 24,
                  right: 24.w + math.max(0, ((MediaQuery.sizeOf(context).width - (48.w)) - ((237 * 2 + 92).w)) / 2),
                  child: GameBottomRightButton(
                    text: 'ابدأ',
                    onTap: () {
                      // التحقق من اختيار المستوى لكلا الفريقين
                      if (team1Level == null || team2Level == null) {
                        ToastHelper.showError(context, 'يرجى اختيار مستوى لكلا الفريقين');
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

                        // طباعة معلومات rounds
                        print('🎯 GameLevelView: ===== ROUND NUMBER UPDATES =====');
                        for (final round in gameStartResponse!.data.rounds) {
                          print('🎯 GameLevelView: Round ${round.id}: round_number ${round.roundNumber}');
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

                        // طباعة قيم pointEarned الحالية لفهم حالة الجولة
                        print('🎯 GameLevelView: Current pointEarned values:');
                        for (int i = 0; i < gameStartResponse!.data.teams.length; i++) {
                          final team = gameStartResponse!.data.teams[i];
                          if (team.roundData.length > currentRoundIndex) {
                            final roundData = team.roundData[currentRoundIndex];
                            print('  Team ${i + 1} roundData[${currentRoundIndex}]: pointEarned = ${roundData.pointEarned}');
                          }
                        }
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

                        // طباعة roundDataId من UpdatePointPlanRequest
                        print('🎯 GameLevelView: ===== UpdatePointPlanRequest roundDataId =====');
                        print('🎯 GameLevelView: team1RoundDataId = $team1RoundDataId');
                        print('🎯 GameLevelView: team2RoundDataId = $team2RoundDataId');
                        print('🎯 GameLevelView: ============================================');

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
                  ),
                ),
              ],
            ),
          ),
        );
        },
      ),
      ));
  }

  void _showGameInstructionsDialog(BuildContext context, gameStartResponse) {
    final notificationCubit = context.read<NotificationCubit>();
    final termsCubit = context.read<TermsCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: notificationCubit),
            BlocProvider.value(value: termsCubit),
          ],
          child: BlocBuilder<TermsCubit, TermsState>(
            builder: (context, termsState) {
              // الحصول على نص التعليمات الحالي (سيتحدث تلقائياً عند تحميل البيانات)
              String termsText = _getTermsText(context);

              // إذا كانت البيانات لا تزال قيد التحميل، اعرض رسالة التحميل
              if (termsState is TermsLoading) {
                termsText = 'جاري تحميل التعليمات...';
              }

              return SubscriptionAlertDialog(
                title: 'تعليمات',
                content: termsText,
                buttonText: 'حسنا',
                onButtonPressed: () {
                  // إغلاق dialog التعليمات فقط (لا ننتقل لأي صفحة)
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          ),
        );
      }
    );
  }


}