import 'package:flutter/material.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/group_card.dart';

class GroupsView extends StatelessWidget {
  const GroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:  [
                GroupCard(title: 'فرقه 01'),
                GroupCard(title: 'فرقه 02'),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
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
            )
          ],
        ),
      ),
    );
  }
}
