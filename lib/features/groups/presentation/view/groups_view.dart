import 'package:flutter/material.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/game/data/models/game_start_request.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/core/widgets/group_card.dart';

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
    // التحقق من وجود البيانات المطلوبة
    if (GlobalStorage.team1Categories.isEmpty || GlobalStorage.team2Categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب اختيار الفئات لكلا الفريقين أولاً'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (GlobalStorage.team1Name.isEmpty || GlobalStorage.team2Name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب إدخال أسماء الفرق'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم بدء اللعبة بنجاح!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // حفظ gameStartResponse في GlobalStorage للاستعادة
          GlobalStorage.lastGameStartResponse = gameState.response;

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
        // فشل - عرض رسالة خطأ
        if (mounted) {
          setState(() {
            _isStartingGame = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(gameState.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // خطأ في الـ API
      if (mounted) {
        setState(() {
          _isStartingGame = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل في بدء اللعبة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      print('💾 تم حفظ اسم الفريق الأول: "${GlobalStorage.team1Name}"');
    };

    _team2Listener = () {
      GlobalStorage.team2Name = _team2Controller.text.trim();
      GlobalStorage.saveGameData(
        team1Cats: GlobalStorage.team1Categories,
        team2Cats: GlobalStorage.team2Categories,
        t1Name: GlobalStorage.team1Name,
        t2Name: GlobalStorage.team2Name,
      );
      print('💾 تم حفظ اسم الفريق الثاني: "${GlobalStorage.team2Name}"');
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
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على بيانات الفئات المختارة من الـ arguments (كحل احتياطي)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && mounted) {
      _team1Categories = args['team1Categories'] ?? [];
      _team2Categories = args['team2Categories'] ?? [];
    }

    return Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
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
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 48),
                      SizedBox(
                        width: 210,
                        child: GroupCard(
                          title: 'فريق 01',
                          controller: _team1Controller,
                          hintText: 'اضف اسم الفريق',
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                onTap: _isStartingGame ? null : () {
                  // طباعة البيانات المختارة
                  print('🎯 الضغط على زر ابدأ');
                  print('🏷️ اسم الفريق الأول: "${_team1Controller.text.trim()}"');
                  print('🏷️ اسم الفريق الثاني: "${_team2Controller.text.trim()}"');
                  print('📋 فئات الفريق الأول: $_team1Categories (${_team1Categories.length} فئة)');
                  print('📋 فئات الفريق الثاني: $_team2Categories (${_team2Categories.length} فئة)');
                  print('📊 المجموع الكلي للفئات: ${_team1Categories.length + _team2Categories.length} فئة');

                  // التحقق من أن أسماء الفرق مكتوبة
                  if (_team1Controller.text.trim().isEmpty ||
                      _team2Controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى إدخال أسماء الفرق الاثنين'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // التحقق من وجود فئات مختارة
                  if (_team1Categories.isEmpty || _team2Categories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى اختيار الفئات لكلا الفريقين'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // حفظ بيانات اللعبة في GlobalStorage
                  GlobalStorage.team1Categories = _team1Categories;
                  GlobalStorage.team2Categories = _team2Categories;
                  GlobalStorage.team1Name = _team1Controller.text.trim();
                  GlobalStorage.team2Name = _team2Controller.text.trim();

                  // بدء اللعبة مباشرة
                  _startGame();
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
          );
  }
}