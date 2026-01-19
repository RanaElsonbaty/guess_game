import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/icons.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/subscription_alert_dialog.dart';
import 'package:guess_game/features/levels/presentation/cubit/categories_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/category_card.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:shimmer/shimmer.dart';

class TeamCategoriesSecondTeamView extends StatefulWidget {
  final int limit;
  final List<int> team1Categories;
  final bool isAddOneCategory;

  const TeamCategoriesSecondTeamView({
    super.key,
    required this.limit,
    required this.team1Categories,
    this.isAddOneCategory = false,
  });

  @override
  State<TeamCategoriesSecondTeamView> createState() => _TeamCategoriesSecondTeamViewState();
}

class _TeamCategoriesSecondTeamViewState extends State<TeamCategoriesSecondTeamView> {
  late List<int> selectedCategoriesForSecondTeam;
  int maxSelectableCategories = 0;
  int userLimit = 0;
  List<int> team1Categories = [];
  bool _didReadArgs = false;
  int _gameId = 0;
  int _team1Id = 0;
  int _team2Id = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _gameId = args['gameId'] as int? ?? 0;
      _team1Id = args['team1Id'] as int? ?? 0;
      _team2Id = args['team2Id'] as int? ?? 0;
    }
  }

  @override
  void initState() {
    super.initState();
    // الحصول على البيانات من widget parameters
    print('🏗️ TeamCategoriesSecondTeamView initState called');
    print('🏗️ limit: ${widget.limit}');
    print('🏗️ team1Categories: ${widget.team1Categories}');

    team1Categories = widget.team1Categories;
    print('📋 team1Categories من widget: $team1Categories');

    // تهيئة قائمة الفئات المختارة
    selectedCategoriesForSecondTeam = [];

    // تحميل الفئات المحفوظة سابقاً
    _loadSavedCategories();

    // تخزين الـ limit المرسل من الصفحة السابقة
    userLimit = widget.limit;
    // كل فريق يمكنه اختيار حتى limit فئة (في add-one: فئة واحدة فقط)
    maxSelectableCategories = widget.isAddOneCategory ? 1 : userLimit;
    print('📋 widget.limit: ${widget.limit}');
    print('📋 userLimit: $userLimit');
    print('📋 team1Categories.length: ${team1Categories.length}');
    print('📋 maxSelectableCategories للفريق الثاني: $maxSelectableCategories');
  }

  void _toggleCategorySelection(int categoryId) {
    setState(() {
      if (selectedCategoriesForSecondTeam.contains(categoryId)) {
        // إلغاء اختيار الفئة
        selectedCategoriesForSecondTeam.remove(categoryId);
        print('❌ إلغاء اختيار الفئة ID: $categoryId');
      } else {
        // التحقق من الحد الأقصى للفريق الثاني (حتى limit فئة)
        if (selectedCategoriesForSecondTeam.length >= maxSelectableCategories) {
          if (widget.isAddOneCategory) {
            _showOneCategoryOnlyDialog();
          }
          return;
        }

        // اختيار الفئة
        selectedCategoriesForSecondTeam.add(categoryId);
        print('✅ اختيار الفئة ID: $categoryId');
        print('📊 التقدم: ${selectedCategoriesForSecondTeam.length}/$maxSelectableCategories فئة');

        // لا نحتاج لإظهار alert في الفريق الثاني
      }

      // حفظ التغييرات
      _saveCategories();
    });
  }

  void _showOneCategoryOnlyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return SubscriptionAlertDialog(
          title: 'تنبيه',
          content: 'مسموح لكل فريق إضافة فئة واحدة فقط',
          buttonText: 'حسناً',
          onButtonPressed: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }


  void _loadSavedCategories() {
    // تحميل الفئات المحفوظة من GlobalStorage
    GlobalStorage.loadGameData();

    // تحميل فئات الفريق الثاني المحفوظة
    selectedCategoriesForSecondTeam = [...GlobalStorage.team2Categories];
    print('📋 تم تحميل فئات الفريق الثاني المحفوظة: $selectedCategoriesForSecondTeam');
  }

  void _saveCategories() async {
    // حفظ الفئات في GlobalStorage
    await GlobalStorage.saveGameData(
      team1Cats: team1Categories,
      team2Cats: selectedCategoriesForSecondTeam,
      t1Name: GlobalStorage.team1Name,
      t2Name: GlobalStorage.team2Name,
    );
    print('💾 تم حفظ فئات الفريق الثاني: $selectedCategoriesForSecondTeam');
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
                      'فئات الفريق 02',
                      style: TextStyles.font14Secondary700Weight,
                    ),
                  ),
                  /// Close button (top right of main container)
                  Positioned(
                    top: -15,
                    right: -15,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(AppIcons.cancel),
                    ),
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
                            // التحقق من رسالة انتهاء الاشتراك
                            if (state.message.contains('لا يمكن اختيار المزيد') ||
                                state.message.contains('المجموع الكلي سيصل 0 فئة')) {
                            // التحقق من subscription
                            final subscription = GlobalStorage.subscription;
                            final remaining = subscription?.limit != null && subscription?.used != null
                                ? subscription!.limit! - subscription.used!
                                : 0;
                            if (subscription == null || subscription.status != 'active' || remaining <= 0) {
                                // إعادة توجيه لصفحة الباقات
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    Routes.packages,
                                    (route) => false,
                                  );
                                });
                                return Center(
                                  child: Text(
                                    'انتهى اشتراكك. جاري إعادة توجيهك لصفحة الباقات...',
                                    style: TextStyles.font14Secondary700Weight.copyWith(
                                      color: Colors.orange,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                            }

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
                              // عرض جميع الفئات المتاحة
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final isSelected = selectedCategoriesForSecondTeam.contains(category.id);

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 20.h,
                                    ),
                                  child: GestureDetector(
                                    onTap: category.status ? () {
                                      _toggleCategorySelection(category.id);
                                      print('🏷️ الفئة: ${category.name} (ID: ${category.id}) للفريق الثاني');
                                      print('📋 الفئات المختارة حالياً: $selectedCategoriesForSecondTeam');
                                    } : null,
                                    behavior: HitTestBehavior.translucent,
                                    child: Stack(
                                        children: [
                                          CategoryCard(
                                            title: category.name,
                                            imageUrl: category.image,
                                            isLocked: !category.status,
                                            isSubscriptionLocked: false, // غير مقفل في صفحة الفريق الثاني
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

          // زر التالي في أسفل يمين الشاشة
          Positioned(
            bottom: 40,
            right: 40,
            child: GestureDetector(
              onTap: () async {
                // منطق التحقق من الاختيارات
                final team1Count = team1Categories.length;
                final team2Count = selectedCategoriesForSecondTeam.length;

                // التحقق من أن كل فريق اختار فئة واحدة على الأقل
                if (team2Count == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يجب على الفريق الثاني اختيار فئة واحدة على الأقل'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (widget.isAddOneCategory) {
                  // In add-one mode: exactly 1 category per team.
                  if (team1Count != 1 || team2Count != 1) {
                    _showOneCategoryOnlyDialog();
                    return;
                  }
                } else {
                  // Normal mode: equal & even categories count
                  if (team1Count != team2Count) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('يجب أن يكون عدد الفئات متساوياً بين الفريقين (الفريق الأول: $team1Count، الفريق الثاني: $team2Count)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (team1Count % 2 != 0 || team2Count % 2 != 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('يجب أن يكون عدد الفئات زوجياً (الفريق الأول: $team1Count، الفريق الثاني: $team2Count)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                // حفظ البيانات في GlobalStorage قبل الانتقال
                await GlobalStorage.saveGameData(
                  team1Cats: team1Categories,
                  team2Cats: selectedCategoriesForSecondTeam,
                  // Preserve names (in add-one flow they must stay prefilled).
                  t1Name: GlobalStorage.team1Name,
                  t2Name: GlobalStorage.team2Name,
                );

                // منطق الانتقال لصفحة GroupsView
                print('🚀 الضغط على زر التالي - الانتقال لصفحة المجموعات');
                print('📋 الفئات المختارة للفريق الأول: $team1Categories ($team1Count فئة)');
                print('📋 الفئات المختارة للفريق الثاني: $selectedCategoriesForSecondTeam ($team2Count فئة)');
                print('✅ تم التحقق من أن العدد زوجي ومتساوي ($team1Count = $team2Count)');
                Navigator.of(context).pushNamed(
                  Routes.groups,
                  arguments: {
                    'team1Categories': team1Categories,
                    'team2Categories': selectedCategoriesForSecondTeam,
                    'isAddOneCategory': widget.isAddOneCategory,
                    'gameId': _gameId,
                    'team1Id': _team1Id,
                    'team2Id': _team2Id,
                  },
                );
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