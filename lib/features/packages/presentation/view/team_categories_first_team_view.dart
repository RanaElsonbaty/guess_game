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
import 'package:guess_game/core/helper_functions/toast_helper.dart';

class TeamCategoriesFirstTeamView extends StatefulWidget {
  final int limit;
  final bool isAddOneCategory;

  const TeamCategoriesFirstTeamView({
    super.key,
    required this.limit,
    this.isAddOneCategory = false,
  });

  @override
  State<TeamCategoriesFirstTeamView> createState() => _TeamCategoriesFirstTeamViewState();
}

class _TeamCategoriesFirstTeamViewState extends State<TeamCategoriesFirstTeamView> {
  late List<int> selectedCategoriesForFirstTeam;
  int maxSelectableCategories = 0;
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
    // تهيئة قائمة الفئات المختارة
    selectedCategoriesForFirstTeam = [];

    // تحميل الفئات المحفوظة سابقاً
    _loadSavedCategories();

    // كل فريق يمكنه اختيار حتى limit فئة (في add-one: فئة واحدة فقط)
    maxSelectableCategories = widget.isAddOneCategory ? 1 : widget.limit;

    // تحميل الفئات من API إذا لم تكن محملة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesCubit = context.read<CategoriesCubit>();
      if (!categoriesCubit.isLoaded) {
        print('📋 TeamCategoriesFirstTeamView: تحميل الفئات من API...');
        categoriesCubit.loadCategories();
      } else {
        print('📋 TeamCategoriesFirstTeamView: الفئات محملة مسبقاً');
        // التحقق من صحة الفئات المحفوظة
        _validateSavedCategories();
      }
    });
  }

  void _toggleCategorySelection(int categoryId) {
    setState(() {
      if (selectedCategoriesForFirstTeam.contains(categoryId)) {
        // إلغاء اختيار الفئة
        selectedCategoriesForFirstTeam.remove(categoryId);
        print('❌ إلغاء اختيار الفئة ID: $categoryId');
      } else {
        // في حالة add-one: فئة واحدة فقط
        if (widget.isAddOneCategory) {
          if (selectedCategoriesForFirstTeam.length >= 1) {
            _showOneCategoryOnlyDialog();
            return;
          }
        } else {
          // التحقق من الحد الأقصى للفريق الأول (حتى limit فئة)
          if (selectedCategoriesForFirstTeam.length >= maxSelectableCategories) {
            return;
          }
        }

        // اختيار الفئة
        selectedCategoriesForFirstTeam.add(categoryId);
        print('✅ اختيار الفئة ID: $categoryId');
        print('📊 التقدم: ${selectedCategoriesForFirstTeam.length} فئة');
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

    // تحميل فئات الفريق الأول المحفوظة
    selectedCategoriesForFirstTeam = [...GlobalStorage.team1Categories];
    print('📋 تم تحميل فئات الفريق الأول المحفوظة: $selectedCategoriesForFirstTeam');

    // تنظيف الفئات المحفوظة التي لم تعد متاحة (سيتم التحقق لاحقاً في BlocBuilder)
    _validateSavedCategories();
  }

  void _validateSavedCategories() {
    // سيتم استدعاء هذا بعد تحميل الفئات من API
    final categoriesCubit = context.read<CategoriesCubit>();
    if (categoriesCubit.isLoaded) {
      final availableCategoryIds = categoriesCubit.categories.map((c) => c.id).toSet();
      final validSavedCategories = selectedCategoriesForFirstTeam.where((id) => availableCategoryIds.contains(id)).toList();

      if (validSavedCategories.length != selectedCategoriesForFirstTeam.length) {
        print('⚠️ تم العثور على فئات محفوظة غير متاحة: ${selectedCategoriesForFirstTeam.where((id) => !availableCategoryIds.contains(id)).toList()}');
        selectedCategoriesForFirstTeam = validSavedCategories;
        print('📋 تم تنظيف الفئات المحفوظة: $selectedCategoriesForFirstTeam');

        // حفظ الفئات الصحيحة
        _saveCategories();
      }
    }
  }

  void _saveCategories() async {
    // حفظ الفئات في GlobalStorage
    await GlobalStorage.saveGameData(
      team1Cats: selectedCategoriesForFirstTeam,
      team2Cats: GlobalStorage.team2Categories,
      t1Name: GlobalStorage.team1Name,
      t2Name: GlobalStorage.team2Name,
    );
    print('💾 تم حفظ فئات الفريق الأول: $selectedCategoriesForFirstTeam');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(AppIcons.cancel),
                  ),
                ),


                /// Categories container
                Positioned(
                  top: 18,
                  left: 10,
                  right: 10,
                  bottom: 20,
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

                          // التحقق من صحة الفئات المحفوظة عند تحميل الفئات من API
                          if (!isLoading && categories.isNotEmpty) {
                            _validateSavedCategories();
                          }

                          if (isLoading) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 20,
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
                                    behavior: HitTestBehavior.translucent,
                                    child: Stack(
                                      children: [
                                        CategoryCard(
                                          title: category.name,
                                          imageUrl: category.image,
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
            bottom: 40,
            right: 40,
            child: GestureDetector(
              onTap: () {
                // منطق التحقق من الاختيارات
                final team1Count = selectedCategoriesForFirstTeam.length;

                // التحقق من أن الفريق الأول اختار فئة واحدة على الأقل
                if (team1Count == 0) {
                  ToastHelper.showError(context, 'يجب على الفريق الأول اختيار فئة واحدة على الأقل');
                  return;
                }

                if (widget.isAddOneCategory) {
                  // في حالة add-one: يجب أن تكون فئة واحدة بالضبط
                  if (team1Count != 1) {
                    _showOneCategoryOnlyDialog();
                    return;
                  }
                }

                // منطق الانتقال لصفحة الفريق الثاني
                print('🚀 الضغط على زر التالي - الانتقال لفئات الفريق الثاني');
                print('📋 الفئات المختارة للفريق الأول: $selectedCategoriesForFirstTeam ($team1Count فئة)');
                // حفظ البيانات الأساسية في GlobalStorage للاستعادة
                GlobalStorage.lastLimit = widget.limit;
                GlobalStorage.lastTeam1Categories = selectedCategoriesForFirstTeam;

                Navigator.of(context).pushNamed(
                  Routes.teamCategoriesSecondTeam,
                  arguments: {
                    'limit': widget.limit,
                    'team1Categories': selectedCategoriesForFirstTeam,
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
    ),
    );
  }
}