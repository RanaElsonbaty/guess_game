import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/images.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/features/levels/presentation/cubit/categories_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/category_card.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:shimmer/shimmer.dart';

class TeamCategoriesFirstTeamView extends StatefulWidget {
  final int limit;

  const TeamCategoriesFirstTeamView({
    super.key,
    required this.limit,
  });

  @override
  State<TeamCategoriesFirstTeamView> createState() => _TeamCategoriesFirstTeamViewState();
}

class _TeamCategoriesFirstTeamViewState extends State<TeamCategoriesFirstTeamView> {
  final List<int> selectedCategoriesForFirstTeam = [];
  int maxSelectableCategories = 0;
  int userLimit = 0;

  @override
  void initState() {
    super.initState();
    // تخزين الـ limit المرسل من الصفحة السابقة
    userLimit = widget.limit;
    maxSelectableCategories = (userLimit / 2).ceil(); // كل فريق يمكنه اختيار حتى limit/2
    print('📋 TeamCategoriesFirstTeamView initState:');
    print('📋 widget.limit: ${widget.limit}');
    print('📋 userLimit: $userLimit');
    print('📋 maxSelectableCategories: $maxSelectableCategories');
  }

  void _toggleCategorySelection(int categoryId) {
    setState(() {
      if (selectedCategoriesForFirstTeam.contains(categoryId)) {
        // إلغاء اختيار الفئة
        selectedCategoriesForFirstTeam.remove(categoryId);
        print('❌ إلغاء اختيار الفئة ID: $categoryId');
      } else {
        // التحقق من عدم تجاوز الحد الأقصى
        if (selectedCategoriesForFirstTeam.length >= maxSelectableCategories) {
          print('⚠️ لا يمكن اختيار المزيد من الفئات (الحد الأقصى: $maxSelectableCategories)');
          _showLimitReachedAlert();
          return;
        }

        // اختيار الفئة
        selectedCategoriesForFirstTeam.add(categoryId);
        print('✅ اختيار الفئة ID: $categoryId');
        print('📊 التقدم: ${selectedCategoriesForFirstTeam.length}/$maxSelectableCategories');

        // إظهار alert عند الوصول للحد الأقصى
        if (selectedCategoriesForFirstTeam.length == maxSelectableCategories) {
          _showLimitReachedAlert();
        }
      }
    });
  }

  void _showLimitReachedAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // لا يمكن إغلاقه بالضغط خارج الـ dialog
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 600,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF79899f).withOpacity(0.3),
                  Color(0xFF8b929b).withOpacity(0.3),
                  Color(0xFF79899f).withOpacity(0.3)
                ],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Header with card image background
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppImages.card),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Cancel icon on the right
                        Positioned(
                          top: 10,
                          right: 10,
                          child: SvgPicture.asset(
                            AppIcons.cancel,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        // Title in center
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              'اشعار',
                              style: TextStyles.font13Secondary700Weight.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Positioned(
                  top: 70,
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'يمكنك اختيار حتى $maxSelectableCategories فئة\nللفريق الأول (من أصل $userLimit إجمالي)',
                        style: TextStyles.font10Secondary700Weight,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),

                      // 3D Green Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 104,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.greenButtonLight,
                                AppColors.greenButtonDark,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'حسنا',
                              style: TextStyles.font10Secondary700Weight.copyWith(
                                color: Colors.white,
                              ),
                            ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // المحتوى الرئيسي
          Center(
            child: Container(
              width: 740.w,
              height: 240.h,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  /// Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0XFF8e8e8e),
                          AppColors.black.withOpacity(.2),
                          Colors.white.withOpacity(.5),
                        ],
                      ),
                    ),
                  ),
                  /// Header (painted) INSIDE main container
                  Positioned(
                    top: -23,
                    left: 0,
                    child: SizedBox(
                      width: 285.w,
                      height: 80.h,
                      child: CustomPaint(
                        painter: HeaderShapePainter(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -13,
                    left: 25,
                    child: Text(
                      'فئات الفريق 01',
                      style: TextStyles.font14Secondary700Weight,
                    ),
                  ),
                  /// Close button (top right of main container)
                  Positioned(
                    top: -15,
                    right: -15,
                    child: SvgPicture.asset(AppIcons.cancel),
                  ),
                  /// Categories container
                  Positioned(
                    top: 18.h,
                    left: 10.w,
                    right: 10.w,
                    bottom: 20.h,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0XFF231F20).withOpacity(.3),
                      ),
                      child: BlocBuilder<CategoriesCubit, CategoriesState>(
                        builder: (context, state) {
                          if (state is CategoriesError) {
                            return Center(
                              child: Text(
                                'خطأ في تحميل الفئات: ${state.message}',
                                style: TextStyles.font14Secondary700Weight.copyWith(
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            // Show shimmer or real categories
                            final isLoading = state is CategoriesLoading;
                            final categories = state is CategoriesLoaded ? state.categories : [];

                            if (isLoading) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  itemCount: 4,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 20.h,
                                      ),
                                      child: const CategoryCard(
                                        title: 'تحميل...',
                                        isLocked: false,
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              final limitedCategories = categories.take(userLimit).toList();
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                itemCount: limitedCategories.length,
                                itemBuilder: (context, index) {
                                  final category = limitedCategories[index];
                                  final isSelected = selectedCategoriesForFirstTeam.contains(category.id);

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 20.h,
                                    ),
                                    child: GestureDetector(
                                      onTap: category.status ? () {
                                        _toggleCategorySelection(category.id);
                                        print('🏷️ الفئة: ${category.name} (ID: ${category.id}) للفريق الأول');
                                        print('📋 الفئات المختارة حالياً: $selectedCategoriesForFirstTeam');
                                      } : null,
                                      child: Stack(
                                        children: [
                                          CategoryCard(
                                            title: category.name,
                                            isLocked: !category.status,
                                            isSubscriptionLocked: false, // غير مقفل في صفحة الفريق الأول
                                            onPressed: null, // إزالة onPressed من CategoryCard
                                          ),
                                          if (isSelected)
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: AppColors.secondaryColor,
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // زر التالي في أسفل يمين الشاشة زي GroupsView
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                print('🎯 تم الضغط على زر التالي!');
                print('📊 عدد الفئات المختارة: ${selectedCategoriesForFirstTeam.length}');

                // منطق التحقق من اختيار الفئات
                if (selectedCategoriesForFirstTeam.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يجب على الفريق الأول اختيار فئة واحدة على الأقل'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // منطق الانتقال لصفحة الفريق الثاني
                print('🚀 الضغط على زر التالي - الانتقال لفئات الفريق الثاني');
                print('📋 الفئات المختارة للفريق الأول: $selectedCategoriesForFirstTeam (${selectedCategoriesForFirstTeam.length} فئة)');
                print('📋 userLimit: $userLimit');
                print('📋 Arguments: {limit: $userLimit, team1Categories: $selectedCategoriesForFirstTeam}');

                print('🔄 بدء عملية الانتقال...');
                print('📦 Arguments: {limit: $userLimit, team1Categories: $selectedCategoriesForFirstTeam}');

                print('🔄 محاولة الانتقال باستخدام pushNamed...');
                try {
                  Navigator.of(context).pushNamed(
                    Routes.teamCategoriesSecondTeam,
                    arguments: {
                      'limit': userLimit,
                      'team1Categories': selectedCategoriesForFirstTeam,
                    },
                  );
                  print('✅ تم الانتقال بنجاح للصفحة الثانية');
                } catch (e) {
                  print('❌ خطأ في الانتقال: $e');
                  print('❌ Stack trace: ${e.toString()}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ في الانتقال: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// 🔸 Main Button Body
                  Container(
                    height: 45,
                    width: 110,
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
            ),
          ),
        ],
      ),
    );
  }
}