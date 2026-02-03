import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/features/settings/data/models/settings_response.dart';
import 'package:guess_game/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/logout_cubit.dart';
import 'package:guess_game/core/widgets/subscription_alert_dialog.dart';
import 'package:guess_game/guess_game.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Future<void> _launchURL(String? url, String platform) async {
    if (url == null || url.isEmpty) {
      developer.log(
        '⚠️ URL is null or empty for $platform',
        name: 'AppDrawer',
      );
      return;
    }
    
    developer.log(
      '🔗 Social Media Click: $platform',
      name: 'AppDrawer',
    );
    developer.log(
      '📱 URL: $url',
      name: 'AppDrawer',
    );
    
    try {
      final uri = Uri.parse(url);
      
      // For mailto and tel, use platformDefault mode instead of externalApplication
      final launchMode = url.startsWith('mailto:') || url.startsWith('tel:')
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication;
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: launchMode);
        developer.log(
          '✅ Successfully launched $platform URL',
          name: 'AppDrawer',
        );
      } else {
        developer.log(
          '❌ Cannot launch URL: $url',
          name: 'AppDrawer',
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error launching URL: $e',
        name: 'AppDrawer',
        error: e,
      );
    }
  }

  void _showSettingsDialog({
    required String title,
    required List<SettingItem> items,
  }) {
    // Logging
    developer.log(
      '📋 Settings Dialog Clicked: $title',
      name: 'AppDrawer',
    );
    developer.log(
      '📄 Items Count: ${items.length}',
      name: 'AppDrawer',
    );
    for (var i = 0; i < items.length; i++) {
      developer.log(
        '📄 Item ${i + 1}:',
        name: 'AppDrawer',
      );
      developer.log(
        '  Title: ${items[i].title}',
        name: 'AppDrawer',
      );
      developer.log(
        '  Content: ${items[i].content}',
        name: 'AppDrawer',
      );
    }
    
    // استخدام context الصفحة الرئيسية من navKey
    final rootContext = GuessGame.navKey.currentContext;
    if (rootContext == null) {
      developer.log(
        '❌ Root context is null',
        name: 'AppDrawer',
      );
      return;
    }
    
    // استخدام rootNavigator لفتح الـ dialog فوق كل شيء
    showDialog(
      context: rootContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400.w,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
            ),
            child: Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF79899f).withOpacity(0.3),
                    const Color(0xFF8b929b).withOpacity(0.3),
                    const Color(0xFF79899f).withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الشريط العلوي
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
                        GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: SvgPicture.asset(
                            AppIcons.cancel,
                            width: 24.w,
                            height: 24.w,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyles.font24Secondary700Weight,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 40.w),
                      ],
                    ),
                  ),
                  // المحتوى
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items.map((item) {
                            developer.log(
                              '📋 Displaying Item in Dialog:',
                              name: 'AppDrawer',
                            );
                            developer.log(
                              '  Title: ${item.title}',
                              name: 'AppDrawer',
                            );
                            developer.log(
                              '  Content: ${item.content}',
                              name: 'AppDrawer',
                            );
                            return Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyles.font16Secondary700Weight,
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    item.content,
                                    style: TextStyles.font14Secondary700Weight.copyWith(
                                      color: AppColors.secondaryColor.withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = GlobalStorage.user;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SettingsCubit>()
            ..loadSettings()
            ..loadSocialMedia()
            ..loadSupportSettings(),
        ),
        BlocProvider(
          create: (context) => getIt<LogoutCubit>(),
        ),
      ],
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF79899f).withOpacity(0.9),
                      const Color(0xFF8b929b).withOpacity(0.9),
                      const Color(0xFF79899f).withOpacity(0.9),
                    ],
                  ),
                ),
          child: Column(
            children: [
              // الشريط العلوي مع بيانات المستخدم
              Container(
                width: double.infinity,
                height: 100.h,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.card),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // أيقونة الإلغاء في الأعلى
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: SvgPicture.asset(
                            AppIcons.cancel,
                            width: 24.w,
                            height: 24.w,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // اسم المستخدم
                    Text(
                      user?.name ?? 'المستخدم',
                      style: TextStyles.font16Secondary700Weight,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 4.h),
                    // إيميل المستخدم
                    Text(
                      user?.email ?? '',
                      style: TextStyles.font14Secondary700Weight.copyWith(
                        color: AppColors.secondaryColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              
              // قائمة الإعدادات
              Expanded(
                child: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    final cubit = context.read<SettingsCubit>();
                    
                    if (state is SettingsLoading && !cubit.isLoaded && !cubit.isSocialMediaLoaded) {
                      return Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Column(
                            children: [
                              // Shimmer for menu items (5 items: الباقات، الفئات، سياسة الخصوصية، الشروط والأحكام، عن التطبيق)
                              _buildShimmerMenuItem(),
                              SizedBox(height: 12.h),
                              _buildShimmerMenuItem(),
                              SizedBox(height: 12.h),
                              _buildShimmerMenuItem(),
                              SizedBox(height: 12.h),
                              _buildShimmerMenuItem(),
                              SizedBox(height: 12.h),
                              _buildShimmerMenuItem(),
                              SizedBox(height: 24.h),
                              // Shimmer for support section
                              _buildShimmerSupportSection(),
                              SizedBox(height: 24.h),
                              // Shimmer for social media
                              _buildShimmerSocialMedia(),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: ListView(
                        children: [
                          // الباقات
                          _buildMenuItem(
                            context: context,
                            title: 'الباقات',
                            onTap: () {
                              developer.log(
                                '📦 Packages Clicked',
                                name: 'AppDrawer',
                              );
                              Navigator.of(context).pop(); // إغلاق الـ drawer
                              Navigator.of(context).pushNamed(Routes.packages);
                            },
                          ),
                          SizedBox(height: 12.h),
                          // الفئات
                          _buildMenuItem(
                            context: context,
                            title: 'الفئات',
                            onTap: () {
                              developer.log(
                                '📚 Categories Clicked',
                                name: 'AppDrawer',
                              );
                              Navigator.of(context).pop(); // إغلاق الـ drawer
                              Navigator.of(context).pushNamed(Routes.level);
                            },
                          ),
                          SizedBox(height: 12.h),
                          // اشتراكاتي
                          _buildMenuItem(
                            context: context,
                            title: 'اشتراكاتي',
                            onTap: () {
                              developer.log(
                                '📋 My Subscriptions Clicked',
                                name: 'AppDrawer',
                              );
                              Navigator.of(context).pop(); // إغلاق الـ drawer
                              Navigator.of(context).pushNamed(Routes.mySubscriptions);
                            },
                          ),
                          SizedBox(height: 12.h),
                          // سياسة الخصوصية
                          _buildMenuItem(
                            context: context,
                            title: 'سياسة الخصوصية',
                            onTap: () {
                              final privacyPolicy = cubit.privacyPolicy;
                              developer.log(
                                '🔒 Privacy Policy Clicked',
                                name: 'AppDrawer',
                              );
                              developer.log(
                                '📊 Privacy Policy Response: ${cubit.privacyPolicy.length} items',
                                name: 'AppDrawer',
                              );
                              // Log full response
                              for (var i = 0; i < privacyPolicy.length; i++) {
                                developer.log(
                                  '📄 Privacy Policy Item ${i + 1}:',
                                  name: 'AppDrawer',
                                );
                                developer.log(
                                  '  Title: ${privacyPolicy[i].title}',
                                  name: 'AppDrawer',
                                );
                                developer.log(
                                  '  Content: ${privacyPolicy[i].content}',
                                  name: 'AppDrawer',
                                );
                              }
                              if (privacyPolicy.isNotEmpty) {
                                Navigator.of(context).pop(); // إغلاق الـ drawer أولاً
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  _showSettingsDialog(
                                    title: 'سياسة الخصوصية',
                                    items: privacyPolicy,
                                  );
                                });
                              } else {
                                developer.log(
                                  '⚠️ Privacy Policy is empty',
                                  name: 'AppDrawer',
                                );
                              }
                            },
                          ),
                          SizedBox(height: 12.h),
                          // الشروط والأحكام
                          _buildMenuItem(
                            context: context,
                            title: 'الشروط والأحكام',
                            onTap: () {
                              final termsAndConditions = cubit.termsAndConditions;
                              developer.log(
                                '📜 Terms and Conditions Clicked',
                                name: 'AppDrawer',
                              );
                              developer.log(
                                '📊 Terms and Conditions Response: ${cubit.termsAndConditions.length} items',
                                name: 'AppDrawer',
                              );
                              // Log full response
                              for (var i = 0; i < termsAndConditions.length; i++) {
                                developer.log(
                                  '📄 Terms and Conditions Item ${i + 1}:',
                                  name: 'AppDrawer',
                                );
                                developer.log(
                                  '  Title: ${termsAndConditions[i].title}',
                                  name: 'AppDrawer',
                                );
                                developer.log(
                                  '  Content: ${termsAndConditions[i].content}',
                                  name: 'AppDrawer',
                                );
                              }
                              if (termsAndConditions.isNotEmpty) {
                                Navigator.of(context).pop(); // إغلاق الـ drawer أولاً
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  _showSettingsDialog(
                                    title: 'الشروط والأحكام',
                                    items: termsAndConditions,
                                  );
                                });
                              } else {
                                developer.log(
                                  '⚠️ Terms and Conditions is empty',
                                  name: 'AppDrawer',
                                );
                              }
                            },
                          ),
                          SizedBox(height: 12.h),
                          // عن التطبيق
                          _buildMenuItem(
                            context: context,
                            title: 'عن التطبيق',
                            onTap: () {
                              final aboutUs = cubit.aboutUs;
                              developer.log(
                                'ℹ️ About Us Clicked',
                                name: 'AppDrawer',
                              );
                              developer.log(
                                '📊 About Us Response: ${cubit.aboutUs.length} items',
                                name: 'AppDrawer',
                              );
                              // Log full response
                              for (var i = 0; i < aboutUs.length; i++) {
                                developer.log(
                                  '📄 About Us Item ${i + 1}:',
                                  name: 'AppDrawer',
                                );
                                developer.log(
                                  '  Title: ${aboutUs[i].title}',
                                  name: 'AppDrawer',
                                );
                                developer.log(
                                  '  Content: ${aboutUs[i].content}',
                                  name: 'AppDrawer',
                                );
                              }
                              if (aboutUs.isNotEmpty) {
                                Navigator.of(context).pop(); // إغلاق الـ drawer أولاً
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  _showSettingsDialog(
                                    title: 'عن التطبيق',
                                    items: aboutUs,
                                  );
                                });
                              } else {
                                developer.log(
                                  '⚠️ About Us is empty',
                                  name: 'AppDrawer',
                                );
                              }
                            },
                          ),
                          SizedBox(height: 24.h),
                          // معلومات الدعم
                          BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, state) {
                              final support = cubit.support;
                              
                              if (state is SupportLoaded || support != null) {
                                final supportData = support ?? (state as SupportLoaded).response.data;
                                
                                final hasAnySupport = 
                                    (supportData.supportEmail != null && supportData.supportEmail!.isNotEmpty) ||
                                    (supportData.supportAddress != null && supportData.supportAddress!.isNotEmpty);
                                
                                if (!hasAnySupport) {
                                  return const SizedBox.shrink();
                                }
                                
                                developer.log(
                                  '📞 Support Data:',
                                  name: 'AppDrawer',
                                );
                                developer.log(
                                  '  Email: ${supportData.supportEmail}',
                                  name: 'AppDrawer',
                                );
                                developer.log(
                                  '  Address: ${supportData.supportAddress}',
                                  name: 'AppDrawer',
                                );
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الدعم',
                                      style: TextStyles.font14Secondary700Weight,
                                    ),
                                    SizedBox(height: 12.h),
                                    if (supportData.supportEmail != null && supportData.supportEmail!.isNotEmpty)
                                      _buildSupportItem(
                                        icon: Icons.email,
                                        label: 'البريد الإلكتروني',
                                        value: supportData.supportEmail!,
                                        onTap: () {
                                          final email = supportData.supportEmail;
                                          if (email != null && email.isNotEmpty) {
                                            _launchURL('mailto:$email', 'Email');
                                          }
                                        },
                                      ),
                                    if (supportData.supportAddress != null && supportData.supportAddress!.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: (supportData.supportEmail != null && supportData.supportEmail!.isNotEmpty)
                                              ? 8.h
                                              : 0,
                                        ),
                                        child: _buildSupportItem(
                                          icon: Icons.location_on,
                                          label: 'العنوان',
                                          value: supportData.supportAddress!,
                                          onTap: null,
                                        ),
                                      ),
                                    SizedBox(height: 12.h), // قللت من 24.h إلى 12.h
                                  ],
                                );
                              }
                              
                              return const SizedBox.shrink();
                            },
                          ),
                          // تسجيل الخروج
                          BlocBuilder<LogoutCubit, LogoutState>(
                            builder: (context, logoutState) {
                              final isLoading = logoutState is LogoutLoading;
                              return Column(
                                children: [
                                  SizedBox(height: 12.h), // قللت من 24.h إلى 12.h
                                  _buildMenuItem(
                                    context: context,
                                    title: 'تسجيل الخروج',
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            developer.log(
                                              '🚪 Logout Clicked',
                                              name: 'AppDrawer',
                                            );
                                            Navigator.of(context).pop(); // إغلاق الـ drawer أولاً
                                            Future.delayed(const Duration(milliseconds: 100), () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (dialogContext) {
                                                  return BlocProvider(
                                                    create: (context) => getIt<LogoutCubit>(), // إنشاء cubit جديد للـ dialog
                                                    child: BlocConsumer<LogoutCubit, LogoutState>(
                                                      listener: (context, state) {
                                                        if (state is LogoutSuccess) {
                                                          developer.log(
                                                            '✅ Logout Success: ${state.response.message}',
                                                            name: 'AppDrawer',
                                                          );
                                                          Navigator.of(dialogContext).pop(); // إغلاق الـ dialog
                                                          Navigator.of(context).pushNamedAndRemoveUntil(
                                                            Routes.intro,
                                                            (route) => false,
                                                          );
                                                        } else if (state is LogoutError) {
                                                          developer.log(
                                                            '❌ Logout Error: ${state.message}',
                                                            name: 'AppDrawer',
                                                          );
                                                          Navigator.of(dialogContext).pop(); // إغلاق الـ dialog حتى لو فشل
                                                        }
                                                      },
                                                      builder: (context, state) {
                                                        final isLoading = state is LogoutLoading;
                                                        return SubscriptionAlertDialog(
                                                          title: 'تسجيل الخروج',
                                                          content: 'هل أنت متأكد من تسجيل الخروج؟',
                                                          buttonText: isLoading ? '' : 'تأكيد', // نص فارغ أثناء التحميل
                                                          secondaryButtonText: 'إلغاء',
                                                          onSecondaryButtonPressed: isLoading 
                                                              ? null 
                                                              : () => Navigator.of(dialogContext).pop(),
                                                          onButtonPressed: isLoading 
                                                              ? null 
                                                              : () {
                                                                  developer.log(
                                                                    '🔄 Starting logout process',
                                                                    name: 'AppDrawer',
                                                                  );
                                                                  context.read<LogoutCubit>().logout(); // استخدام الـ cubit الجديد
                                                                },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            });
                                          },
                                  ),
                                ],
                              );
                            },
                          ),
                          // وسائل التواصل الاجتماعي
                          BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, state) {
                              final socialMedia = cubit.socialMedia;
                              
                              // إذا كان الـ state هو SocialMediaLoaded أو إذا كان socialMedia موجود
                              if (state is SocialMediaLoaded || socialMedia != null) {
                                final media = socialMedia ?? (state as SocialMediaLoaded).response.data;
                                
                                final hasAnySocialMedia = 
                                    (media.facebook != null && media.facebook!.isNotEmpty) ||
                                    (media.instagram != null && media.instagram!.isNotEmpty) ||
                                    (media.twitter != null && media.twitter!.isNotEmpty) ||
                                    (media.snapchat != null && media.snapchat!.isNotEmpty) ||
                                    (media.linkedin != null && media.linkedin!.isNotEmpty) ||
                                    (media.youtube != null && media.youtube!.isNotEmpty);
                                
                                if (!hasAnySocialMedia) {
                                  return const SizedBox.shrink();
                                }
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تابعنا على',
                                      style: TextStyles.font14Secondary700Weight,
                                    ),
                                    SizedBox(height: 12.h),
                                    Wrap(
                                      spacing: 12.w,
                                      runSpacing: 12.h,
                                      children: [
                                        if (media.facebook != null && media.facebook!.isNotEmpty)
                                          _buildSocialIcon(
                                            icon: Icons.facebook,
                                            onTap: () {
                                              developer.log(
                                                '📱 Social Media Response - Facebook: ${media.facebook}',
                                                name: 'AppDrawer',
                                              );
                                              _launchURL(media.facebook, 'Facebook');
                                            },
                                          ),
                                        if (media.instagram != null && media.instagram!.isNotEmpty)
                                          _buildSocialIcon(
                                            icon: Icons.camera_alt,
                                            onTap: () {
                                              developer.log(
                                                '📱 Social Media Response - Instagram: ${media.instagram}',
                                                name: 'AppDrawer',
                                              );
                                              _launchURL(media.instagram, 'Instagram');
                                            },
                                          ),
                                        if (media.twitter != null && media.twitter!.isNotEmpty)
                                          _buildSocialIcon(
                                            icon: Icons.alternate_email,
                                            onTap: () {
                                              developer.log(
                                                '📱 Social Media Response - Twitter: ${media.twitter}',
                                                name: 'AppDrawer',
                                              );
                                              _launchURL(media.twitter, 'Twitter');
                                            },
                                          ),
                                        if (media.snapchat != null && media.snapchat!.isNotEmpty)
                                          _buildSocialIcon(
                                            icon: Icons.camera,
                                            onTap: () {
                                              developer.log(
                                                '📱 Social Media Response - Snapchat: ${media.snapchat}',
                                                name: 'AppDrawer',
                                              );
                                              _launchURL(media.snapchat, 'Snapchat');
                                            },
                                          ),
                                        if (media.linkedin != null && media.linkedin!.isNotEmpty)
                                          _buildSocialIcon(
                                            icon: Icons.business,
                                            onTap: () {
                                              developer.log(
                                                '📱 Social Media Response - LinkedIn: ${media.linkedin}',
                                                name: 'AppDrawer',
                                              );
                                              _launchURL(media.linkedin, 'LinkedIn');
                                            },
                                          ),
                                        if (media.youtube != null && media.youtube!.isNotEmpty)
                                          _buildSocialIcon(
                                            icon: Icons.play_circle_filled,
                                            onTap: () {
                                              developer.log(
                                                '📱 Social Media Response - YouTube: ${media.youtube}',
                                                name: 'AppDrawer',
                                              );
                                              _launchURL(media.youtube, 'YouTube');
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withOpacity(.3),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyles.font14Secondary700Weight.copyWith(
                  color: onTap == null 
                      ? AppColors.secondaryColor.withOpacity(0.5)
                      : AppColors.secondaryColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: onTap == null 
                  ? AppColors.secondaryColor.withOpacity(0.5)
                  : AppColors.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withOpacity(.3),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.secondaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.secondaryColor,
          size: 20.w,
        ),
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withOpacity(.3),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: AppColors.secondaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.secondaryColor,
              size: 18.w,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyles.font10Secondary700Weight.copyWith(
                      color: AppColors.secondaryColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyles.font14Secondary700Weight,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14.w,
                color: AppColors.secondaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerMenuItem() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 16.h,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 16.w,
            height: 16.h,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title shimmer
        Container(
          height: 16.h,
          width: 60.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 12.h),
        // Support items shimmer (3 items: email, phone, address)
        _buildShimmerSupportItem(),
        SizedBox(height: 8.h),
        _buildShimmerSupportItem(),
        SizedBox(height: 8.h),
        _buildShimmerSupportItem(),
      ],
    );
  }

  Widget _buildShimmerSupportItem() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          Container(
            width: 18.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  height: 12.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSocialMedia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: List.generate(6, (index) {
            return Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}

