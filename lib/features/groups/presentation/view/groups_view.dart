import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/helper_functions/toast_helper.dart';
import 'package:guess_game/core/widgets/subscription_alert_dialog.dart';
import 'package:guess_game/features/game/data/models/game_start_request.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/repeat_game_request.dart';
import 'package:guess_game/features/game/presentation/cubit/add_one_round_cubit.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/game/presentation/cubit/repeat_game_cubit.dart';
import 'package:guess_game/core/widgets/group_card.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_drawer_icon.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupsView extends StatefulWidget {
  const GroupsView({super.key});

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  final TextEditingController _team1Controller = TextEditingController();
  final TextEditingController _team2Controller = TextEditingController();
  late final VoidCallback _team1Listener;
  late final VoidCallback _team2Listener;

  List<int> _team1Categories = [];
  List<int> _team2Categories = [];
  bool _isStartingGame = false;
  bool _isAddOneFlow = false;
  bool _isSameGamePackageFlow = false;
  bool _isReplayFlow = false;
  int _replayGameId = 0;
  int _addOneGameId = 0;
  int _addOneTeam1Id = 0;
  int _addOneTeam2Id = 0;
  bool _hasLoadedReplayData = false; // Flag to track if replay data has been loaded

  @override
  void dispose() {
    // إزالة الـ listeners قبل dispose
    _team1Controller.removeListener(_team1Listener);
    _team2Controller.removeListener(_team2Listener);

    _team1Controller.dispose();
    _team2Controller.dispose();
    super.dispose();
  }






  void _startGame() async {
    setState(() {
      _isStartingGame = true;
    });
    
    // Check if this is a replay flow - call repeat game API
    if (_isReplayFlow && _replayGameId > 0) {
      print('🔄 المستخدم ضغط على "التالي" - استدعاء API تكرار اللعبة...');
      await _repeatGame();
      return;
    }
    
    // التحقق من وجود البيانات المطلوبة
    if (GlobalStorage.team1Categories.isEmpty || GlobalStorage.team2Categories.isEmpty) {
      if (mounted) {
        ToastHelper.showError(context, 'يجب اختيار الفئات لكلا الفريقين أولاً');
      }
      setState(() {
        _isStartingGame = false;
      });
      return;
    }

    if (GlobalStorage.team1Name.isEmpty || GlobalStorage.team2Name.isEmpty) {
      if (mounted) {
        ToastHelper.showError(context, 'يجب إدخال أسماء الفرق');
      }
      setState(() {
        _isStartingGame = false;
      });
      return;
    }

    // إنشاء request لبدء اللعبة
    final gameRequest = GameStartRequest(
      teams: [
        GameTeam(
          teamNumber: 1,
          name: GlobalStorage.team1Name,
          categoriesIds: GlobalStorage.team1Categories,
        ),
        GameTeam(
          teamNumber: 2,
          name: GlobalStorage.team2Name,
          categoriesIds: GlobalStorage.team2Categories,
        ),
      ],
    );

    try {
      // تنفيذ API call
      final gameCubit = getIt<GameCubit>();
      await gameCubit.startGame(gameRequest);

      // انتظار قليلاً لمعالجة النتيجة
      await Future.delayed(const Duration(milliseconds: 500));

      final gameState = gameCubit.state;
      if (gameState is GameStarted) {
        // نجاح - الانتقال إلى GameLevelView
        if (mounted) {
          setState(() {
            _isStartingGame = false;
          });
          ToastHelper.showSuccess(context, '✅ تم بدء اللعبة بنجاح!');
          // حفظ gameStartResponse في GlobalStorage للاستعادة
          GlobalStorage.lastGameStartResponse = gameState.response;
          await GlobalStorage.saveGameStartResponse(gameState.response);

          Navigator.of(context).pushReplacementNamed(
            Routes.gameLevel,
            arguments: {
              'team1Name': GlobalStorage.team1Name,
              'team2Name': GlobalStorage.team2Name,
              'gameStartResponse': gameState.response,
            },
          );
        }
      } else if (gameState is GameStartError) {
        // فشل - التحقق من نوع الخطأ
        if (mounted) {
          setState(() {
            _isStartingGame = false;
          });
          
          // التحقق إذا كان الخطأ متعلق بالاشتراك
          final errorMessage = gameState.message.toLowerCase();
          if (errorMessage.contains('subscription') || 
              errorMessage.contains('اشتراك') || 
              errorMessage.contains('انتهى') ||
              errorMessage.contains('expired') ||
              errorMessage.contains('limit')) {
            _showSubscriptionRequiredDialog();
          } else {
            ToastHelper.showError(context, gameState.message);
          }
        }
      }
    } catch (e) {
      // خطأ في الـ API
      if (mounted) {
        setState(() {
          _isStartingGame = false;
        });
        ToastHelper.showError(context, '❌ فشل في بدء اللعبة: $e');
      }
    }
  }

  Future<void> _repeatGame() async {
    // Create repeat game request with current team names
    final request = RepeatGameRequest(
      gameId: _replayGameId,
      teams: [
        RepeatGameTeam(
          name: _team1Controller.text.trim(),
          teamNumber: 1,
        ),
        RepeatGameTeam(
          name: _team2Controller.text.trim(),
          teamNumber: 2,
        ),
      ],
    );

    print('🔄 استدعاء /games/copy-game API...');
    print('📤 game_id: $_replayGameId');
    print('📤 teams: [');
    print('  {name: "${_team1Controller.text.trim()}", team_number: 1},');
    print('  {name: "${_team2Controller.text.trim()}", team_number: 2}');
    print(']');

    setState(() {
      _isStartingGame = true;
    });

    try {
      // Call repeat game API through cubit
      await context.read<RepeatGameCubit>().repeatGame(request);
    } catch (e) {
      print('❌ خطأ في استدعاء API: $e');
      if (mounted) {
        setState(() {
          _isStartingGame = false;
        });
        ToastHelper.showError(context, '❌ فشل في تكرار اللعبة: $e');
      }
    }
  }

  void _showSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return SubscriptionAlertDialog(
          title: 'اشتراك مطلوب',
          content: 'يجب الاشتراك في باقة جديدة لبدء اللعبة',
          buttonText: 'اشتراك',
          secondaryButtonText: 'إلغاء',
          onSecondaryButtonPressed: () => Navigator.of(dialogContext).pop(),
          onButtonPressed: () {
            Navigator.of(dialogContext).pop();
            
            // حفظ بيانات اللعبة الحالية للاستعادة بعد الدفع
            GlobalStorage.lastRouteArguments = {
              'team1Name': GlobalStorage.team1Name,
              'team2Name': GlobalStorage.team2Name,
              'team1Categories': GlobalStorage.team1Categories,
              'team2Categories': GlobalStorage.team2Categories,
              'isReplayAfterPayment': true, // علامة للعودة إلى GroupsView بعد الدفع
            };
            
            // الانتقال إلى صفحة الباقات
            Navigator.of(context).pushNamed(Routes.packages);
          },
        );
      },
    );
  }

  GameStartResponse? _resolveCurrentGameStart() {
    final gs = GlobalStorage.gameStartResponse;
    if (gs is GameStartResponse) return gs;
    final last = GlobalStorage.lastGameStartResponse;
    if (last is GameStartResponse) return last;
    return null;
  }

  Future<void> _addOneRoundAndStartCycle() async {
    setState(() {
      _isStartingGame = true;
    });

    if (GlobalStorage.team1Categories.length != 1 || GlobalStorage.team2Categories.length != 1) {
      if (!mounted) return;
      setState(() => _isStartingGame = false);
      ToastHelper.showError(context, 'مسموح لكل فريق إضافة فئة واحدة فقط');
      return;
    }

    // Prefer IDs passed from GameWinnerView -> OptionsView -> Categories -> Groups.
    // Fallback to in-session gameStartResponse if needed.
    int gameId = _addOneGameId;
    int team1Id = _addOneTeam1Id;
    int team2Id = _addOneTeam2Id;

    if (gameId == 0 || team1Id == 0 || team2Id == 0) {
      final gameStart = _resolveCurrentGameStart();
      if (gameStart != null) {
        gameId = gameStart.data.id;
        final team1 = gameStart.data.teams.firstWhere(
          (t) => t.teamNumber == 1,
          orElse: () => gameStart.data.teams[0],
        );
        final team2 = gameStart.data.teams.firstWhere(
          (t) => t.teamNumber == 2,
          orElse: () => gameStart.data.teams.length > 1 ? gameStart.data.teams[1] : gameStart.data.teams[0],
        );
        team1Id = team1.id;
        team2Id = team2.id;
      }
    }

    if (gameId == 0 || team1Id == 0 || team2Id == 0) {
      if (!mounted) return;
      setState(() => _isStartingGame = false);
      ToastHelper.showError(context, 'لا يمكن تحديد بيانات اللعبة لإضافة جولة جديدة');
      return;
    }

    // حفظ عدد الراوندات القديمة قبل إضافة الراوند الجديد
    final oldRoundsCount = GlobalStorage.currentRoundIndex + 1;
    print('📊 [AddOne] عدد الراوندات القديمة المكتملة: $oldRoundsCount');
    print('📊 [AddOne] currentRoundIndex قبل الإضافة: ${GlobalStorage.currentRoundIndex}');
    
    // حفظ في GlobalStorage مع علامة isAddOneFlow
    GlobalStorage.lastRouteArguments = {
      ...GlobalStorage.lastRouteArguments ?? {},
      'oldRoundsCount': oldRoundsCount,
      'isAddOneFlow': true, // علامة للتعرف على add-one flow
    };

    await context.read<AddOneRoundCubit>().addRounds(
          gameId: gameId,
          team1Id: team1Id,
          team2Id: team2Id,
          team1CategoryId: GlobalStorage.team1Categories.first,
          team2CategoryId: GlobalStorage.team2Categories.first,
        );
  }

  Future<void> _addSameGamePackageRounds() async {
    setState(() {
      _isStartingGame = true;
    });

    final team1Count = GlobalStorage.team1Categories.length;
    final team2Count = GlobalStorage.team2Categories.length;
    final totalCount = team1Count + team2Count;

    // التحقق من القواعد: عدد >= 1، متساوي، مجموع زوجي
    if (team1Count == 0 || team2Count == 0) {
      if (!mounted) return;
      setState(() => _isStartingGame = false);
      ToastHelper.showError(context, 'يجب على كل فريق اختيار فئة واحدة على الأقل');
      return;
    }

    if (team1Count != team2Count) {
      if (!mounted) return;
      setState(() => _isStartingGame = false);
      ToastHelper.showError(context, 'يجب أن يكون عدد الفئات متساوياً بين الفريقين (الفريق الأول: $team1Count، الفريق الثاني: $team2Count)');
      return;
    }

    if (totalCount % 2 != 0) {
      if (!mounted) return;
      setState(() => _isStartingGame = false);
      ToastHelper.showError(context, 'المجموع الكلي للفئات يجب أن يكون زوجياً (حالياً: $totalCount)');
      return;
    }

    // الحصول على gameId و teamIds - الأولوية من arguments ثم من GlobalStorage.lastRouteArguments
    int gameId = _addOneGameId;
    int team1Id = _addOneTeam1Id;
    int team2Id = _addOneTeam2Id;

    if (gameId == 0 || team1Id == 0 || team2Id == 0) {
      final gameArgs = GlobalStorage.lastRouteArguments;
      gameId = gameArgs['gameId'] as int? ?? gameId;
      team1Id = gameArgs['team1Id'] as int? ?? team1Id;
      team2Id = gameArgs['team2Id'] as int? ?? team2Id;
      
      // تحديث المتغيرات المحلية للاستخدام لاحقاً
      _addOneGameId = gameId;
      _addOneTeam1Id = team1Id;
      _addOneTeam2Id = team2Id;
    }

    if (gameId == 0 || team1Id == 0 || team2Id == 0) {
      final gameStart = _resolveCurrentGameStart();
      if (gameStart != null) {
        gameId = gameStart.data.id;
        final team1 = gameStart.data.teams.firstWhere(
          (t) => t.teamNumber == 1,
          orElse: () => gameStart.data.teams[0],
        );
        final team2 = gameStart.data.teams.firstWhere(
          (t) => t.teamNumber == 2,
          orElse: () => gameStart.data.teams.length > 1 ? gameStart.data.teams[1] : gameStart.data.teams[0],
        );
        team1Id = team1.id;
        team2Id = team2.id;
      }
    }

    if (gameId == 0 || team1Id == 0 || team2Id == 0) {
      if (!mounted) return;
      setState(() => _isStartingGame = false);
      ToastHelper.showError(context, 'لا يمكن تحديد بيانات اللعبة لإضافة جولات جديدة');
      return;
    }

    // حفظ عدد الراوندات القديمة قبل إضافة الجديدة
    final oldRoundsCount = GlobalStorage.currentRoundIndex + 1;
    print('📊 عدد الراوندات القديمة المكتملة: $oldRoundsCount');
    print('📊 currentRoundIndex قبل الإضافة: ${GlobalStorage.currentRoundIndex}');
    
    // حفظ في GlobalStorage للاستخدام بعد نجاح الـ API
    GlobalStorage.lastRouteArguments = {
      ...GlobalStorage.lastRouteArguments ?? {},
      'oldRoundsCount': oldRoundsCount,
    };

    // استخدام AddOneRoundCubit لإضافة الجولات مع فئات متعددة
    await context.read<AddOneRoundCubit>().addRoundsWithMultipleCategories(
          gameId: gameId,
          team1Id: team1Id,
          team2Id: team2Id,
          team1CategoriesIds: GlobalStorage.team1Categories,
          team2CategoriesIds: GlobalStorage.team2Categories,
        );
  }

  @override
  void initState() {
    super.initState();

    // إعداد listeners لحفظ الأسماء فوراً عند التغيير
    _team1Listener = () {
      GlobalStorage.team1Name = _team1Controller.text.trim();
      GlobalStorage.saveGameData(
        team1Cats: GlobalStorage.team1Categories,
        team2Cats: GlobalStorage.team2Categories,
        t1Name: GlobalStorage.team1Name,
        t2Name: GlobalStorage.team2Name,
      );
      print('💾 تم حفظ اسم الفريق الأول: "${GlobalStorage.team1Name}" (من controller: "${_team1Controller.text}")');
    };

    _team2Listener = () {
      GlobalStorage.team2Name = _team2Controller.text.trim();
      GlobalStorage.saveGameData(
        team1Cats: GlobalStorage.team1Categories,
        team2Cats: GlobalStorage.team2Categories,
        t1Name: GlobalStorage.team1Name,
        t2Name: GlobalStorage.team2Name,
      );
      print('💾 تم حفظ اسم الفريق الثاني: "${GlobalStorage.team2Name}" (من controller: "${_team2Controller.text}")');
    };

    // إضافة الـ listeners للـ controllers
    _team1Controller.addListener(_team1Listener);
    _team2Controller.addListener(_team2Listener);

    // تحميل بيانات اللعبة من GlobalStorage إذا كانت متوفرة
    if (GlobalStorage.team1Categories.isNotEmpty || GlobalStorage.team2Categories.isNotEmpty) {
      _team1Categories = GlobalStorage.team1Categories;
      _team2Categories = GlobalStorage.team2Categories;
      if (GlobalStorage.team1Name.isNotEmpty) {
        _team1Controller.text = GlobalStorage.team1Name;
      }
      if (GlobalStorage.team2Name.isNotEmpty) {
        _team2Controller.text = GlobalStorage.team2Name;
      }
    }

    // Load replay data from route arguments if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['isReplay'] == true && !_hasLoadedReplayData) {
        _isReplayFlow = true;
        _replayGameId = args['gameId'] as int? ?? 0;
        
        final team1Name = args['team1Name'] as String? ?? '';
        final team2Name = args['team2Name'] as String? ?? '';
        final team1CategoriesRaw = args['team1Categories'] as List<dynamic>? ?? [];
        final team2CategoriesRaw = args['team2Categories'] as List<dynamic>? ?? [];
        
        // Convert List<dynamic> to List<int>
        final team1Categories = team1CategoriesRaw.map((e) => e as int).toList();
        final team2Categories = team2CategoriesRaw.map((e) => e as int).toList();
        
        // Set controller text only once when loading replay data
        if (team1Name.isNotEmpty) {
          print('🔧 تعيين اسم الفريق الأول: $team1Name');
          _team1Controller.text = team1Name;
          GlobalStorage.team1Name = team1Name;
        }
        if (team2Name.isNotEmpty) {
          print('🔧 تعيين اسم الفريق الثاني: $team2Name');
          _team2Controller.text = team2Name;
          GlobalStorage.team2Name = team2Name;
        }
        print('🎮 تم تحميل أسماء الفرق من جولاتي: $team1Name, $team2Name');
        print('🔧 حالة الـ controllers بعد التحميل:');
        print('  - _team1Controller.text: "${_team1Controller.text}"');
        print('  - _team2Controller.text: "${_team2Controller.text}"');
        
        // Load categories for replay
        if (team1Categories.isNotEmpty && team2Categories.isNotEmpty) {
          _team1Categories = team1Categories;
          _team2Categories = team2Categories;
          GlobalStorage.team1Categories = team1Categories;
          GlobalStorage.team2Categories = team2Categories;
          print('🎮 تم تحميل فئات الفرق من جولاتي: $team1Categories, $team2Categories');
        }
        
        _hasLoadedReplayData = true; // Mark as loaded to prevent repeated loading
        setState(() {}); // Trigger rebuild to show the loaded data
        
        // Don't call API automatically - wait for user to click "التالي"
        print('✅ تم تحميل بيانات تكرار اللعب - في انتظار ضغط المستخدم على "التالي"');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على بيانات الفئات المختارة من الـ arguments (كحل احتياطي)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && mounted) {
      // Convert List<dynamic> to List<int> safely
      final team1CategoriesRaw = args['team1Categories'];
      final team2CategoriesRaw = args['team2Categories'];
      
      if (team1CategoriesRaw is List) {
        _team1Categories = team1CategoriesRaw.map((e) => e as int).toList();
      }
      if (team2CategoriesRaw is List) {
        _team2Categories = team2CategoriesRaw.map((e) => e as int).toList();
      }
      
      _isAddOneFlow = args['isAddOneCategory'] == true;
      _isSameGamePackageFlow = args['isSameGamePackage'] == true;
      _addOneGameId = args['gameId'] as int? ?? _addOneGameId;
      _addOneTeam1Id = args['team1Id'] as int? ?? _addOneTeam1Id;
      _addOneTeam2Id = args['team2Id'] as int? ?? _addOneTeam2Id;
      
      // في حالة isSameGamePackageFlow، تأكد من تحميل الأسماء من GlobalStorage
      if (_isSameGamePackageFlow) {
        if (GlobalStorage.team1Name.isNotEmpty && _team1Controller.text != GlobalStorage.team1Name) {
          _team1Controller.text = GlobalStorage.team1Name;
        }
        if (GlobalStorage.team2Name.isNotEmpty && _team2Controller.text != GlobalStorage.team2Name) {
          _team2Controller.text = GlobalStorage.team2Name;
        }
        print('📋 تم تحميل أسماء الفرق من GlobalStorage: ${GlobalStorage.team1Name}, ${GlobalStorage.team2Name}');
      }
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<AddOneRoundCubit, AddOneRoundState>(
          listener: (context, state) {
            if (state is AddOneRoundSuccess) {
              if (!mounted) return;
              setState(() => _isStartingGame = false);
              print('✅ API Response: ${state.response.message}');
              
              // الحصول على عدد الراوندات القديمة والـ flow type من GlobalStorage
              final oldRoundsCount = GlobalStorage.lastRouteArguments?['oldRoundsCount'] as int? ?? 0;
              final isAddOneFlow = GlobalStorage.lastRouteArguments?['isAddOneFlow'] as bool? ?? false;
              
              // إعادة تعيين currentRoundIndex للراوند الأول الجديد
              if (oldRoundsCount > 0) {
                GlobalStorage.currentRoundIndex = oldRoundsCount;
                if (isAddOneFlow) {
                  print('🔄 [AddOne] تم إعادة تعيين currentRoundIndex إلى: ${GlobalStorage.currentRoundIndex}');
                } else {
                  print('🔄 [SameGamePackage] تم إعادة تعيين currentRoundIndex إلى: ${GlobalStorage.currentRoundIndex}');
                }
              } else {
                // fallback: استخدام الطريقة القديمة
                GlobalStorage.currentRoundIndex = 0;
                print('🔄 تم إعادة تعيين currentRoundIndex إلى: 0 (fallback)');
              }
              
              print('📊 عدد الراوندات الكلي بعد الإضافة: ${state.response.data.rounds.length}');
              print('📊 الراوند الحالي (currentRoundIndex): ${GlobalStorage.currentRoundIndex}');
              
              // تحديث gameStartResponse في GlobalStorage
              GlobalStorage.updateGameStartResponse(state.response);
              
              Navigator.of(context).pushReplacementNamed(
                Routes.gameLevel,
                arguments: {
                  'team1Name': GlobalStorage.team1Name,
                  'team2Name': GlobalStorage.team2Name,
                  'gameStartResponse': state.response,
                },
              );
            } else if (state is AddOneRoundError) {
              if (!mounted) return;
              setState(() => _isStartingGame = false);
              print('❌ API Error: ${state.message}');
            }
          },
        ),
        BlocListener<RepeatGameCubit, RepeatGameState>(
          listener: (context, state) {
            if (state is RepeatGameSuccess) {
              if (!mounted) return;
              setState(() => _isStartingGame = false);
              ToastHelper.showSuccess(context, '✅ تم تكرار اللعبة بنجاح!');
              
              // Convert RepeatGameResponse to GameStartResponse
              final gameStartResponse = GameStartResponse.fromJson({
                'success': state.response.success,
                'message': state.response.message,
                'code': state.response.code,
                'data': {
                  'id': state.response.data.id,
                  'name': state.response.data.name,
                  'status': state.response.data.status,
                  'user_id': state.response.data.userId,
                  'created_at': state.response.data.createdAt,
                  'updated_at': state.response.data.updatedAt,
                  'teams': state.response.data.teams.map((team) => {
                    'id': team.id,
                    'game_id': state.response.data.id,
                    'team_number': team.teamNumber,
                    'name': team.name,
                    'image': null,
                    'is_winner': team.isWinner,
                    'created_at': state.response.data.createdAt,
                    'updated_at': state.response.data.updatedAt,
                    'total_points': team.totalPoints,
                    'round_data': team.roundData.map((rd) => {
                      'id': rd.id,
                      'round_id': rd.roundId,
                      'team_id': rd.teamId,
                      'category_id': rd.categoryId,
                      'point_plan': rd.pointPlan,
                      'status': 'draw',
                      'point_earned': rd.pointEarned,
                      'qr_code': rd.qrCode,
                      'question_number': rd.questionNumber,
                      'answer_number': rd.answerNumber,
                      'created_at': state.response.data.createdAt,
                      'updated_at': state.response.data.updatedAt,
                      'image_path': rd.imagePath,
                      'max_answers': rd.maxAnswers,
                      'max_questions': rd.maxQuestions,
                    }).toList(),
                  }).toList(),
                  'rounds': state.response.data.rounds.map((round) => {
                    'id': round.id,
                    'game_id': state.response.data.id,
                    'subscription_id': 0,
                    'round_number': round.roundNumber,
                    'created_at': state.response.data.createdAt,
                    'updated_at': state.response.data.updatedAt,
                    'round_data': round.roundData.map((rd) => {
                      'id': rd.id,
                      'round_id': rd.roundId,
                      'team_id': rd.teamId,
                      'category_id': rd.categoryId,
                      'point_plan': rd.pointPlan,
                      'status': 'draw',
                      'point_earned': rd.pointEarned,
                      'qr_code': rd.qrCode,
                      'question_number': rd.questionNumber,
                      'answer_number': rd.answerNumber,
                      'created_at': state.response.data.createdAt,
                      'updated_at': state.response.data.updatedAt,
                      'image_path': rd.imagePath,
                      'max_answers': rd.maxAnswers,
                      'max_questions': rd.maxQuestions,
                    }).toList(),
                  }).toList(),
                },
                'meta_data': state.response.metaData,
              });
              
              // Save to GlobalStorage
              GlobalStorage.lastGameStartResponse = gameStartResponse;
              GlobalStorage.saveGameStartResponse(gameStartResponse);

              Navigator.of(context).pushReplacementNamed(
                Routes.gameLevel,
                arguments: {
                  'team1Name': _team1Controller.text.trim(),
                  'team2Name': _team2Controller.text.trim(),
                  'gameStartResponse': gameStartResponse,
                  'isReplay': true,
                },
              );
            } else if (state is RepeatGameError) {
              if (!mounted) return;
              setState(() => _isStartingGame = false);
              ToastHelper.showError(context, state.message);
            }
          },
        ),
      ],
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            drawer: const AppDrawer(),
            body: Stack(
              children: [
                // Drawer icon (top left)
                Positioned(
                  top: 6.h,
                  left: 6.w,
                  child: GameDrawerIcon(),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.ltr,
                    children: [
                      SizedBox(
                        width: 210,
                        child: GroupCard(
                          title: 'فريق 02',
                          controller: _team2Controller,
                          hintText: 'اضف اسم الفريق',
                          onChanged: (value) {
                            print('🔄 تم تغيير اسم الفريق الثاني إلى: "$value"');
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(width: 80.w),
                      SizedBox(
                        width: 210,
                        child: GroupCard(
                          title: 'فريق 01',
                          controller: _team1Controller,
                          hintText: 'اضف اسم الفريق',
                          onChanged: (value) {
                            print('🔄 تم تغيير اسم الفريق الأول إلى: "$value"');
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Start button aligned to the right bottom of the screen
            Positioned(
              bottom: 24,
              right: 24.w,
              child: GestureDetector(
                onTap: _isStartingGame ? null : () {
                  // طباعة البيانات المختارة
                  print('🎯 الضغط على زر التالي');
                  print('🏷️ اسم الفريق الأول: "${_team1Controller.text.trim()}"');
                  print('🏷️ اسم الفريق الثاني: "${_team2Controller.text.trim()}"');
                  print('🔄 وضع تكرار اللعب: $_isReplayFlow');
                  
                  // التحقق من أن أسماء الفرق مكتوبة
                  if (_team1Controller.text.trim().isEmpty ||
                      _team2Controller.text.trim().isEmpty) {
                    ToastHelper.showError(context, 'يرجى إدخال أسماء الفرق الاثنين');
                    return;
                  }

                  // في حالة تكرار اللعب، لا نحتاج للتحقق من الفئات
                  if (_isReplayFlow) {
                    print('🔄 وضع تكرار اللعب - تجاهل validation الفئات');
                    print('📤 استدعاء /games/copy-game مع:');
                    print('   game_id: $_replayGameId');
                    print('   teams: [');
                    print('     {name: "${_team1Controller.text.trim()}", team_number: 1},');
                    print('     {name: "${_team2Controller.text.trim()}", team_number: 2}');
                    print('   ]');
                    
                    // حفظ أسماء الفرق في GlobalStorage
                    GlobalStorage.team1Name = _team1Controller.text.trim();
                    GlobalStorage.team2Name = _team2Controller.text.trim();
                    
                    // استدعاء repeat game مباشرة
                    _startGame();
                    return;
                  }

                  // في الحالات الأخرى، التحقق من الفئات
                  print('📋 فئات الفريق الأول: $_team1Categories (${_team1Categories.length} فئة)');
                  print('📋 فئات الفريق الثاني: $_team2Categories (${_team2Categories.length} فئة)');
                  print('📊 المجموع الكلي للفئات: ${_team1Categories.length + _team2Categories.length} فئة');

                  // التحقق من وجود فئات مختارة
                  if (_team1Categories.isEmpty || _team2Categories.isEmpty) {
                    ToastHelper.showError(context, 'يرجى اختيار الفئات لكلا الفريقين');
                    return;
                  }

                  // حفظ بيانات اللعبة في GlobalStorage
                  GlobalStorage.team1Categories = _team1Categories;
                  GlobalStorage.team2Categories = _team2Categories;
                  GlobalStorage.team1Name = _team1Controller.text.trim();
                  GlobalStorage.team2Name = _team2Controller.text.trim();
                  
                  // في حالة isSameGamePackageFlow، استخدام الأسماء المحفوظة (لا تطلب من المستخدم)
                  if (_isSameGamePackageFlow) {
                    // التأكد من وجود الأسماء في GlobalStorage
                    if (GlobalStorage.team1Name.isEmpty) {
                      GlobalStorage.team1Name = _team1Controller.text.trim();
                    }
                    if (GlobalStorage.team2Name.isEmpty) {
                      GlobalStorage.team2Name = _team2Controller.text.trim();
                    }
                    // التأكد من أن الحقول مملوءة بالأسماء المحفوظة
                    if (_team1Controller.text.trim().isEmpty && GlobalStorage.team1Name.isNotEmpty) {
                      _team1Controller.text = GlobalStorage.team1Name;
                    }
                    if (_team2Controller.text.trim().isEmpty && GlobalStorage.team2Name.isNotEmpty) {
                      _team2Controller.text = GlobalStorage.team2Name;
                    }
                  } else {
                    // في الحالات الأخرى، حفظ الأسماء من الحقول
                    GlobalStorage.team1Name = _team1Controller.text.trim();
                    GlobalStorage.team2Name = _team2Controller.text.trim();
                  }

                  // التحقق من وجود أسماء الفرق (خاصة في حالة isSameGamePackageFlow)
                  if (GlobalStorage.team1Name.isEmpty || GlobalStorage.team2Name.isEmpty) {
                    ToastHelper.showError(context, 'يجب إدخال أسماء الفرق');
                    return;
                  }

                  // بدء اللعبة مباشرة
                  if (_isAddOneFlow) {
                    _addOneRoundAndStartCycle();
                  } else if (_isSameGamePackageFlow) {
                    _addSameGamePackageRounds();
                  } else {
                    _startGame();
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
                            child: _isStartingGame
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                                    ),
                                  )
                                : Text(
                                    'التالي',
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
      );
  }
}