import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:guess_game/features/notifications/presentation/cubit/notification_state.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/green_pill_button.dart';

class SubscriptionAlertDialog extends StatefulWidget {
  final String title;
  final String? content; // Make content optional
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  const SubscriptionAlertDialog({
    super.key,
    this.title = 'اشعار',
    this.content, // Optional content parameter
    this.buttonText = 'شراء الان',
    this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  });

  @override
  State<SubscriptionAlertDialog> createState() => _SubscriptionAlertDialogState();
}

class _SubscriptionAlertDialogState extends State<SubscriptionAlertDialog> {
  NotificationCubit? _maybeNotificationCubit(BuildContext context) {
    try {
      return BlocProvider.of<NotificationCubit>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Load notification messages only when needed (and only if NotificationCubit exists).
    if (widget.content == null) {
      final notificationCubit = _maybeNotificationCubit(context);
      notificationCubit?.getNotificationMessages();
    }
  }

  void _defaultPrimaryAction() {
    // إغلاق الحوار أولاً
    Navigator.of(context).pop();
    // ثم الانتقال إلى صفحة الباقات عبر routes
    Navigator.of(context).pushNamed(Routes.packages);
  }

  Widget _buildDialogBody({required String content}) {
    final primaryAction = widget.onButtonPressed ?? _defaultPrimaryAction;

    return Dialog(
      backgroundColor: Colors.transparent, // خلفية شفافة تماماً
      child: Container(
        width: 400.w,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF79899f).withOpacity(0.3), // خفيف جداً
              const Color(0xFF8b929b).withOpacity(0.3), // خفيف جداً
              const Color(0xFF79899f).withOpacity(0.3), // خفيف جداً
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الشريط العلوي مع الأيقونة وكلمة اشعار
            Container(
              width: double.infinity,
              height: 60.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.card),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // أيقونة الإلغاء على اليمين
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      AppIcons.cancel,
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                  // كلمة في الوسط
                  Text(
                    widget.title,
                    style: TextStyles.font24Secondary700Weight,
                    textAlign: TextAlign.center,
                  ),
                  // مساحة فارغة على اليسار
                  SizedBox(width: 40.w),
                ],
              ),
            ),

            // المحتوى الشفاف
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: const BoxDecoration(
                color: Colors.transparent, // شفاف تماماً
              ),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    content,
                    style: TextStyles.font16Secondary700Weight,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),

                  if (widget.secondaryButtonText != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GreenPillButton(
                          width: 104,
                          height: 40,
                          onTap: widget.onSecondaryButtonPressed ?? () => Navigator.of(context).pop(),
                          child: Text(
                            widget.secondaryButtonText!,
                            style: TextStyles.font10Secondary700Weight.copyWith(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        GreenPillButton(
                          width: 104,
                          height: 40,
                          onTap: primaryAction,
                          child: Text(
                            widget.buttonText,
                            style: TextStyles.font10Secondary700Weight.copyWith(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    GreenPillButton(
                      width: 104,
                      height: 40,
                      onTap: primaryAction,
                      child: Text(
                        widget.buttonText,
                        style: TextStyles.font10Secondary700Weight.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If content is provided, we don't depend on NotificationCubit at all.
    if (widget.content != null) {
      return _buildDialogBody(content: widget.content!);
    }

    // Otherwise, try to read content from NotificationCubit if available.
    final notificationCubit = _maybeNotificationCubit(context);
    if (notificationCubit == null) {
      return _buildDialogBody(content: 'يجب اختيار احد الباقات لدينا لكي يتم البدء اللعبه');
    }

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        String content = 'يجب اختيار احد الباقات لدينا لكي يتم البدء اللعبه';
        if (state is NotificationLoaded) {
          content = state.notificationMessages.data.notSubscribedMessage;
        }
        return _buildDialogBody(content: content);
      },
    );
  }
}