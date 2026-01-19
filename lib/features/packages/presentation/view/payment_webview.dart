import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/auth_cubit.dart';

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({super.key, required this.url});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkPaymentSuccess() async {
    try {
      if (_webViewController != null) {
        // فحص عنوان الصفحة
        final title = await _webViewController!.getTitle();
        print('📄 عنوان صفحة الدفع: $title');

        if (title != null &&
            (title.contains('نجح') ||
             title.contains('success') ||
             title.contains('تم') ||
             title.contains('completed') ||
             title.contains('شكراً'))) {
          print('🎉 تم اكتشاف نجاح الدفع!');
          _showSuccessAndNavigate();
          return;
        }

        // فحص HTML content
        final html = await _webViewController!.evaluateJavascript(source: "document.body.innerText");
        final content = html.toString().toLowerCase();
        print('📄 محتوى صفحة الدفع: $content');

        if (content.contains('نجح') ||
            content.contains('success') ||
            content.contains('تم') ||
            content.contains('completed') ||
            content.contains('شكراً') ||
            content.contains('thank you')) {
          print('🎉 تم اكتشاف نجاح الدفع من المحتوى!');
          _showSuccessAndNavigate();
        }
      }
    } catch (e) {
      print('❌ خطأ في فحص نجاح الدفع: $e');
    }
  }

  void _showSuccessAndNavigate() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إكمال الدفع بنجاح! سيتم توجيهك لصفحة اختيار الفئات...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      try {
        // تحديث بيانات المستخدم من API بعد الدفع الناجح
        final authCubit = getIt<AuthCubit>();
        await authCubit.getProfile();

        await Future.delayed(const Duration(milliseconds: 100));

        final authState = authCubit.state;
        if (authState is ProfileLoaded) {
          final user = authState.user;

          // تحديث GlobalStorage بالبيانات الجديدة
          GlobalStorage.user = user;
          GlobalStorage.subscription = user.subscription;

          // حفظ البيانات في التخزين المحلي
          await GlobalStorage.saveUserData(user);
          await GlobalStorage.saveSubscription(user.subscription);

          print('✅ تم تحديث بيانات المستخدم بعد الدفع:');
          print('  - User: ${user.name}');
          print('  - Subscription: ${user.subscription}');

          final limit = user.subscription?.limit ?? 4;

          if (user.subscription != null) {
            print('  - Status: ${user.subscription!.status}');
            print('  - Used: ${user.subscription!.used}');
            print('  - Limit: $limit');
          }

          // انتظار ثم الانتقال باستخدام الـ limit المحدث
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.teamCategories,
                (route) => false,
                arguments: {'limit': limit},
              );
            }
          });
        } else {
          print('❌ فشل في تحديث بيانات المستخدم، سيتم استخدام القيمة الافتراضية');

          // في حالة فشل تحديث البيانات، استخدم القيمة الافتراضية
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.teamCategories,
                (route) => false,
                arguments: {'limit': 4}, // قيمة افتراضية أفضل من 20
              );
            }
          });
        }
      } catch (e) {
        print('❌ خطأ في تحديث بيانات المستخدم: $e');

        // في حالة الخطأ، استخدم القيمة الافتراضية
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.teamCategories,
              (route) => false,
              arguments: {'limit': 4}, // قيمة افتراضية أفضل من 20
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8, // 80% من ارتفاع الشاشة
        width: MediaQuery.of(context).size.width * 0.9, // 90% من عرض الشاشة
        child: Column(
          children: [
            // Header مع أزرار التحكم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'صفحة الدفع',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () {
                      _webViewController?.reload();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // WebView body
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.url))),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        useShouldOverrideUrlLoading: true,
                        useOnLoadResource: true,
                        // تحسينات لحقول الإدخال
                        supportZoom: false,
                        disableHorizontalScroll: true,
                        disableVerticalScroll: false,
                        // تحسين الأداء العام
                        cacheEnabled: true,
                        clearCache: false,
                        // تحسين التفاعل مع المستخدم
                        allowFileAccessFromFileURLs: true,
                        allowUniversalAccessFromFileURLs: true,
                      ),
                      android: AndroidInAppWebViewOptions(
                        // تحسينات خاصة بـ Android
                        useHybridComposition: true,
                        allowFileAccess: true,
                        allowContentAccess: true,
                        // تحسين حقول الإدخال
                        hardwareAcceleration: true,
                        supportMultipleWindows: false,
                        // تحسين الأداء
                        databaseEnabled: true,
                        domStorageEnabled: true,
                        geolocationEnabled: false,
                      ),
                      ios: IOSInAppWebViewOptions(
                        // تحسينات خاصة بـ iOS
                        allowsInlineMediaPlayback: true,
                        allowsAirPlayForMediaPlayback: false,
                        allowsPictureInPictureMediaPlayback: false,
                        // تحسين حقول الإدخال
                        allowsLinkPreview: false,
                        suppressesIncrementalRendering: false,
                      ),
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      print('🌐 تم إنشاء WebView');
                    },
                    onLoadStart: (controller, url) {
                      print('🌐 بدء تحميل صفحة الدفع: $url');
                      setState(() {
                        _isLoading = true;
                      });
                    },
                    onLoadStop: (controller, url) async {
                      print('✅ انتهاء تحميل صفحة الدفع: $url');
                      setState(() {
                        _isLoading = false;
                      });

                      // فحص محتوى الصفحة للكشف عن نجاح الدفع
                      await _checkPaymentSuccess();
                    },
                    onLoadError: (controller, url, code, message) {
                      print('❌ خطأ في تحميل صفحة الدفع: $message');
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      final url = navigationAction.request.url?.toString() ?? '';
                      print('🧭 طلب تنقل: $url');

                      // السماح بجميع التنقلات
                      return NavigationActionPolicy.ALLOW;
                    },
                    gestureRecognizers: Set()
                      ..add(Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                      ))
                      ..add(Factory<HorizontalDragGestureRecognizer>(
                        () => HorizontalDragGestureRecognizer(),
                      ))
                      ..add(Factory<TapGestureRecognizer>(
                        () => TapGestureRecognizer(),
                      )),
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('جاري تحميل صفحة الدفع...'),
                          ],
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
}