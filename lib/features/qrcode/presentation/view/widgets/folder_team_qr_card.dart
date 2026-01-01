import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/file_shape_clipper.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/green_pill_button.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/qr_code_visual.dart';

class FolderTeamQrCard extends StatefulWidget {
  final String teamTitle;
  final String qrCode;
  final int? questionsCount;
  final int? answersCount;
  final int maxQuestions;
  final int maxAnswers;
  final double width;
  final double height;
  final double qrBoxSize;
  final bool canUpdateQuestions;
  final bool canUpdateAnswers;
  final void Function(int questions, int answers)? onScoreChanged;

  const FolderTeamQrCard({
    super.key,
    required this.teamTitle,
    required this.qrCode,
    required this.questionsCount,
    required this.answersCount,
    this.maxQuestions = 20,
    this.maxAnswers = 2,
    this.width = 237,
    this.height = 240,
    this.qrBoxSize = 150,
    this.canUpdateQuestions = true,
    this.canUpdateAnswers = true,
    this.onScoreChanged,
  });

  @override
  State<FolderTeamQrCard> createState() => _FolderTeamQrCardState();
}

class _FolderTeamQrCardState extends State<FolderTeamQrCard> {
  late int _questions;
  late int _answers;

  @override
  void initState() {
    super.initState();
    _questions = _clamp(widget.questionsCount ?? 0, 0, widget.maxQuestions);
    _answers = _clamp(widget.answersCount ?? 0, 0, widget.maxAnswers);
    widget.onScoreChanged?.call(_questions, _answers);
  }

  @override
  void didUpdateWidget(covariant FolderTeamQrCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If upstream values change (new response), refresh local state.
    if (oldWidget.questionsCount != widget.questionsCount ||
        oldWidget.maxQuestions != widget.maxQuestions) {
      _questions = _clamp(widget.questionsCount ?? _questions, 0, widget.maxQuestions);
    }
    if (oldWidget.answersCount != widget.answersCount ||
        oldWidget.maxAnswers != widget.maxAnswers) {
      _answers = _clamp(widget.answersCount ?? _answers, 0, widget.maxAnswers);
    }
    widget.onScoreChanged?.call(_questions, _answers);
  }

  int _clamp(int v, int min, int max) => v < min ? min : (v > max ? max : v);

  void _incQuestions() => setState(() {
        _questions = _clamp(_questions + 1, 0, widget.maxQuestions);
        widget.onScoreChanged?.call(_questions, _answers);
      });
  void _decQuestions() => setState(() {
        _questions = _clamp(_questions - 1, 0, widget.maxQuestions);
        widget.onScoreChanged?.call(_questions, _answers);
      });
  void _incAnswers() => setState(() {
        _answers = _clamp(_answers + 1, 0, widget.maxAnswers);
        widget.onScoreChanged?.call(_questions, _answers);
      });
  void _decAnswers() => setState(() {
        _answers = _clamp(_answers - 1, 0, widget.maxAnswers);
        widget.onScoreChanged?.call(_questions, _answers);
      });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FileClipper(),
      child: Container(
        width: widget.width.w,
        height: widget.height.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0XFF8e8e8e),
              AppColors.black.withOpacity(.3),
              Colors.white.withOpacity(.5),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 35.h, bottom: 12.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Column(
              children: [
                Text(widget.teamTitle, style: TextStyles.font14Secondary700Weight),
                SizedBox(height: 10.h),

                Expanded(
                  child: Center(
                    child: Container(
                      width: widget.qrBoxSize.w,
                      height: widget.qrBoxSize.w,
                      color: Colors.black.withOpacity(0.18),
                      padding: EdgeInsets.all(10.w),
                      child: QrCodeVisual(qr: widget.qrCode),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QrStatTile(
                      label: 'اسئله',
                      value: _questions,
                      onInc: _incQuestions,
                      onDec: _decQuestions,
                      canInc: widget.canUpdateQuestions && _questions < widget.maxQuestions,
                      canDec: widget.canUpdateQuestions && _questions > 0,
                    ),
                    SizedBox(width: 25.w),
                    _QrStatTile(
                      label: 'اجوبه',
                      value: _answers,
                      onInc: _incAnswers,
                      onDec: _decAnswers,
                      canInc: widget.canUpdateAnswers && _answers < widget.maxAnswers,
                      canDec: widget.canUpdateAnswers && _answers > 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QrStatTile extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final bool canInc;
  final bool canDec;

  const _QrStatTile({
    required this.label,
    required this.value,
    required this.onInc,
    required this.onDec,
    required this.canInc,
    required this.canDec,
  });

  @override
  Widget build(BuildContext context) {
    final title = '$label\\$value';
    return SizedBox(
      width: 84.w,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyles.font10Secondary700Weight.copyWith(fontSize: 12.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          GreenPillButton(
            width: 74,
            height: 26,
            onTap: null,
            child: _PillArrowsRow(
              onInc: onInc,
              onDec: onDec,
              canInc: canInc,
              canDec: canDec,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillArrowsRow extends StatelessWidget {
  final VoidCallback onInc;
  final VoidCallback onDec;
  final bool canInc;
  final bool canDec;

  const _PillArrowsRow({
    required this.onInc,
    required this.onDec,
    required this.canInc,
    required this.canDec,
  });

  @override
  Widget build(BuildContext context) {
    final decColor = canDec ? AppColors.secondaryColor : AppColors.secondaryColor.withOpacity(0.35);
    final incColor = canInc ? AppColors.secondaryColor : AppColors.secondaryColor.withOpacity(0.35);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        // Ensure physical left/right stay consistent even in RTL.
        textDirection: TextDirection.ltr,
        children: [
          InkWell(
            onTap: canDec ? onDec : null,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 3.h),
              child: Icon(Icons.remove, size: 18.sp, color: decColor),
            ),
          ),
          const Spacer(),
          Container(
            width: 2.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.75),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: canInc ? onInc : null,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 3.h),
              child: Icon(Icons.add, size: 18.sp, color: incColor),
            ),
          ),
        ],
      ),
    );
  }
}


