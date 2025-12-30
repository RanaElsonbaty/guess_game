import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_response.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/guess_game.dart';

class QrcodeView extends StatefulWidget {
  const QrcodeView({super.key});

  @override
  State<QrcodeView> createState() => _QrcodeViewState();
}

class QrcodeViewWithProvider extends StatelessWidget {
  const QrcodeViewWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final gameCubit = context.read<GameCubit>();
    return BlocProvider.value(
      value: gameCubit,
      child: const QrcodeView(),
    );
  }
}

class _QrcodeViewState extends State<QrcodeView> {
  UpdatePointPlanResponse? updatePointPlanResponse;

  @override
  void initState() {
    super.initState();
    // الحصول على response من arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final Map<String, dynamic>? globalArgs = GuessGame.globalInitialArguments as Map<String, dynamic>?;

      print('🎯 QrcodeView: args = $args');
      print('🎯 QrcodeView: globalArgs = $globalArgs');

      final Map<String, dynamic>? effectiveArgs = args ?? globalArgs;

      if (effectiveArgs != null) {
        setState(() {
          updatePointPlanResponse = effectiveArgs['updatePointPlanResponse'];
        });
        print('🎯 QrcodeView: updatePointPlanResponse = $updatePointPlanResponse');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          children: [
            // عنوان الصفحة
            const Text(
              'رموز QR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // عرض QR codes
            if (updatePointPlanResponse != null &&
                updatePointPlanResponse!.data.roundData.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // عدد الأعمدة
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1, // مربع
                  ),
                  itemCount: updatePointPlanResponse!.data.roundData.length,
                  itemBuilder: (context, index) {
                    final roundData = updatePointPlanResponse!.data.roundData[index];
                    return _buildQrCodeContainer(
                      qrCodeUrl: roundData.qrCode,
                      teamName: 'الفريق ${roundData.teamId}',
                      categoryId: roundData.categoryId,
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'جاري تحميل رموز QR...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),

            const Spacer(),

            // زر العودة أو المتابعة
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // العودة للصفحة السابقة أو المتابعة للعب
                  Navigator.of(context).pop();
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
                        'العودة',
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

  Widget _buildQrCodeContainer({
    required String qrCodeUrl,
    required String teamName,
    required int categoryId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // اسم الفريق
          Text(
            teamName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // ID الفئة
          Text(
            'فئة $categoryId',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // QR Code
          Expanded(
            child: qrCodeUrl.isNotEmpty
                ? SvgPicture.network(
                    qrCodeUrl,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.qr_code,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
