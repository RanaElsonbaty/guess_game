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
import 'package:guess_game/features/levels/presentation/view/widgets/simple_category_card.dart';
import 'package:guess_game/features/levels/presentation/view/widgets/header_shape_painter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:guess_game/core/helper_functions/toast_helper.dart';
import 'package:guess_game/core/widgets/app_drawer.dart';
import 'package:guess_game/features/qrcode/presentation/view/widgets/game_drawer_icon.dart';

class TeamCategoriesSecondTeamView extends StatefulWidget {
  final int limit;
  final List<int> team1Categories;
  final bool isAddOneCategory;
  final bool isSameGamePackage;

  const TeamCategoriesSecondTeamView({
    super.key,
    required this.limit,
    required this.team1Categories,
    this.isAddOneCategory = false,
    this.isSameGamePackage = false,
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
        final team1Count = team1Categories.length;
        final currentTeam2Count = selectedCategoriesForSecondTeam.length;
        
        if (widget.isAddOneCategory) {
          // في حالة add-one: فئة واحدة فقط
          if (currentTeam2Count >= 1) {
            _showOneCategoryOnlyDialog();
            return;
          }
        } else {
          // في الوضع العادي: يمكن اختيار حتى limit فئة
          final newCount = currentTeam2Count + 1;
          
          // التحقق من الحد الأقصى (limit)
          if (newCount > widget.limit) {
            ToastHelper.showWarning(context, 'يمكن اختيار حتى ${widget.limit} فئة فقط');
            return;
          }
        }

        // اختيار الفئة
        selectedCategoriesForSecondTeam.add(categoryId);
        print('✅ اختيار الفئة ID: $categoryId');
        print('📊 التقدم: ${selectedCategoriesForSecondTeam.length} فئة (الفريق الأول: $team1Count)');
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
    return SafeArea(
      child: Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Drawer icon (top left)
          Positioned(
            top: 6.h,
            left: 6.w,
            child: GameDrawerIcon(),
          ),
          // المحتوى الرئيسي
          Positioned(
            top: 85.h, // نزله أكثر ليكون بعيد عن الدراور
            left: 20.w,
            right: 0,
            child: Center(
              child: Container(
                width: 700.w,
                height: 200.h, // صغر الارتفاع من 240 إلى 200
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
                    top: 18,
                    left: 10,
                    right: 10,
                    bottom: 0,
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
                                child: GridView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, // 4 كروت في الصف
                                    crossAxisSpacing: 8.w,
                                    mainAxisSpacing: 8.h,
                                    childAspectRatio: 1.6, // نسبة العرض للارتفاع
                                  ),
                                  itemCount: 8, // 8 كروت شيمر (صفين × 4)
                                  itemBuilder: (context, index) {
                                    return const SimpleCategoryCard(
                                      title: 'تحميل...',
                                      isLocked: false,
                                    );
                                  },
                                ),
                              );
                            } else {
                              // عرض جميع الفئات المتاحة في GridView
                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4, // 4 كروت في الصف
                                  crossAxisSpacing: 8.w,
                                  mainAxisSpacing: 8.h,
                                  childAspectRatio: 1.6, // نسبة العرض للارتفاع
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final isSelected = selectedCategoriesForSecondTeam.contains(category.id);

                                  return SimpleCategoryCard(
                                    title: category.name,
                                    imageUrl: category.image,
                                    isLocked: !category.status,
                                    isSelected: isSelected,
                                    onTap: category.status ? () {
                                      _toggleCategorySelection(category.id);
                                      print('🏷️ الفئة: ${category.name} (ID: ${category.id}) للفريق الثاني');
                                      print('📋 الفئات المختارة حالياً: $selectedCategoriesForSecondTeam');
                                    } : null,
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
          ),
          // زر التالي في أسفل يمين الشاشة
          Positioned(
            bottom: 30.h,
            right: 45.w,
            child: GestureDetector(
              onTap: () async {
                // منطق التحقق من الاختيارات
                final team1Count = team1Categories.length;
                final team2Count = selectedCategoriesForSecondTeam.length;

                if (widget.isAddOneCategory) {
                  // In add-one mode: exactly 1 category per team.
                  if (team1Count != 1 || team2Count != 1) {
                    _showOneCategoryOnlyDialog();
                    return;
                  }
                } else {
                  // Normal mode: كل فريق يجب أن يختار عدد فئات = limit بالضبط
                  
                  // التحقق من أن الفريق الأول اختار العدد الصحيح
                  if (team1Count != widget.limit) {
                    ToastHelper.showError(context, 'يجب على الفريق الأول اختيار ${widget.limit} فئة بالضبط (مختار حالياً: $team1Count)');
                    return;
                  }

                  // التحقق من أن الفريق الثاني اختار العدد الصحيح
                  if (team2Count != widget.limit) {
                    ToastHelper.showError(context, 'يجب على الفريق الثاني اختيار ${widget.limit} فئة بالضبط (مختار حالياً: $team2Count)');
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
                print('✅ تم التحقق: كل فريق اختار ${widget.limit} فئة بالضبط');
                Navigator.of(context).pushNamed(
                  Routes.groups,
                  arguments: {
                    'team1Categories': team1Categories,
                    'team2Categories': selectedCategoriesForSecondTeam,
                    'isAddOneCategory': widget.isAddOneCategory,
                    'isSameGamePackage': widget.isSameGamePackage,
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