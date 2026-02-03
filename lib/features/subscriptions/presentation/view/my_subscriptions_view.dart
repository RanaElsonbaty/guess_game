import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_drawer_icon.dart';
import 'package:intl/intl.dart';

class MySubscriptionsView extends StatefulWidget {
  const MySubscriptionsView({super.key});

  @override
  State<MySubscriptionsView> createState() => _MySubscriptionsViewState();
}

class _MySubscriptionsViewState extends State<MySubscriptionsView> {
  @override
  Widget build(BuildContext context) {
    final user = GlobalStorage.user;
    final subscription = user?.subscription;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content container
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: 75.h, bottom: 28.h, left: 0, right: 24.w),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: (255 * 2 + 92).w,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Background gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0XFF8e8e8e),
                                  AppColors.black.withOpacity(.2),
                                  Colors.white.withOpacity(.5),
                                ],
                              ),
                            ),
                          ),

                          // Header (painted) + title
                          Positioned(
                            top: -23,
                            left: 0,
                            child: SizedBox(
                              width: 285.w,
                              height: 80.h,
                              child: CustomPaint(painter: HeaderShapePainter()),
                            ),
                          ),
                          Positioned(
                            top: -13,
                            left: 25,
                            child: Text(
                              'اشتراكاتي',
                              style: TextStyles.font14Secondary700Weight,
                            ),
                          ),

                          // Close button
                          Positioned(
                            top: -15,
                            right: -15,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: SvgPicture.asset(AppIcons.cancel),
                            ),
                          ),

                          // Content area
                          Positioned(
                            top: 18.h,
                            left: 10.w,
                            right: 10.w,
                            bottom: 20.h,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0XFF231F20).withOpacity(.3),
                              ),
                              child: subscription != null
                                  ? _buildSubscriptionContent(subscription)
                                  : _buildNoSubscriptionContent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Drawer icon (top left)
            Positioned(
              top: 6.h,
              left: 6.w,
              child: GameDrawerIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(SubscriptionModel subscription) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF668899),
                    Color(0XFF617685),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.secondaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(subscription.status),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          _getStatusText(subscription.status),
                          style: TextStyles.font12Secondary700Weight.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'رقم الاشتراك: ${subscription.id ?? 'غير محدد'}',
                        style: TextStyles.font12Secondary700Weight.copyWith(
                          color: AppColors.secondaryColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Usage Progress
                  _buildUsageSection(subscription),
                  SizedBox(height: 16.h),

                  // Subscription Details
                  _buildDetailRow('السعر', '${subscription.price ?? 'غير محدد'} ريال'),
                  SizedBox(height: 8.h),
                  _buildDetailRow('طريقة الدفع', subscription.paymentMethod ?? 'غير محدد'),
                  SizedBox(height: 8.h),
                  
                  if (subscription.startDate != null)
                    _buildDetailRow(
                      'تاريخ البداية',
                      DateFormat('yyyy/MM/dd').format(subscription.startDate!),
                    ),
                  if (subscription.startDate != null) SizedBox(height: 8.h),
                  
                  if (subscription.expiresAt != null)
                    _buildDetailRow(
                      'تاريخ الانتهاء',
                      DateFormat('yyyy/MM/dd').format(subscription.expiresAt!),
                    ),
                  if (subscription.expiresAt != null) SizedBox(height: 8.h),
                  
                  if (subscription.createdAt != null)
                    _buildDetailRow(
                      'تاريخ الإنشاء',
                      DateFormat('yyyy/MM/dd').format(subscription.createdAt!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSection(SubscriptionModel subscription) {
    final used = subscription.used ?? 0;
    final limit = subscription.limit ?? 0;
    final remaining = limit - used;
    final progress = limit > 0 ? used / limit : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاستخدام',
          style: TextStyles.font14Secondary700Weight,
        ),
        SizedBox(height: 8.h),
        
        // Progress Bar
        Container(
          width: double.infinity,
          height: 8.h,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progress >= 1.0 ? Colors.red : AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        
        // Usage Numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المستخدم: $used',
              style: TextStyles.font12Secondary700Weight.copyWith(
                color: AppColors.secondaryColor.withOpacity(0.8),
              ),
            ),
            Text(
              '',
             // 'المتبقي: $remaining',
              style: TextStyles.font12Secondary700Weight.copyWith(
                color: remaining > 0 ? Colors.green : Colors.red,
              ),
            ),
            Text(
              'الإجمالي: $limit',
              style: TextStyles.font12Secondary700Weight.copyWith(
                color: AppColors.secondaryColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.font12Secondary700Weight.copyWith(
            color: AppColors.secondaryColor.withOpacity(0.7),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyles.font12Secondary700Weight,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildNoSubscriptionContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 64.w,
            color: AppColors.secondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد اشتراكات',
            style: TextStyles.font16Secondary700Weight,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم العثور على أي اشتراكات نشطة',
            style: TextStyles.font14Secondary700Weight.copyWith(
              color: AppColors.secondaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'expired':
        return 'منتهي';
      case 'pending':
        return 'في الانتظار';
      default:
        return 'غير محدد';
    }
  }
}