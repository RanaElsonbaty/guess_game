import 'package:flutter/material.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/game_level/presentation/view/widgets/game_level_card.dart';

class GameLevelView extends StatefulWidget {
  const GameLevelView({super.key});

  @override
  State<GameLevelView> createState() => _GameLevelViewState();
}

class _GameLevelViewState extends State<GameLevelView> {
  String? team1Level;
  String? team2Level;

  @override
  Widget build(BuildContext context) {
    // الحصول على أسماء الفرق من الـ arguments
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String team1Name = args?['team1Name'] ?? 'فريق 01';
    final String team2Name = args?['team2Name'] ?? 'فريق 02';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          children: [
            // كاردات الفرق
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameLevelCard(
                  teamName: team1Name,
                  teamTitle: 'فريق 01',
                  onLevelSelected: (level) {
                    setState(() {
                      team1Level = level;
                    });
                  },
                ),
                const SizedBox(width: 48),
                GameLevelCard(
                  teamName: team2Name,
                  teamTitle: 'فريق 02',
                  onLevelSelected: (level) {
                    setState(() {
                      team2Level = level;
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

                  // منطق البدء في اللعب
                  print('🚀 بدء اللعب');
                  print('📋 فريق 01: $team1Name - مستوى: $team1Level');
                  print('📋 فريق 02: $team2Name - مستوى: $team2Level');

                  // TODO: الانتقال إلى صفحة اللعب
                  // Navigator.pushNamed(context, Routes.game, arguments: {
                  //   'team1Name': team1Name,
                  //   'team2Name': team2Name,
                  //   'team1Level': team1Level,
                  //   'team2Level': team2Level,
                  // });
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
    );
  }
}