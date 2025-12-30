import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

  void _showSuccessAndNavigate() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إكمال الدفع بنجاح! سيتم توجيهك لصفحة اختيار الفئات...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // انتظار 3 ثوانٍ ثم العودة لصفحة الباقات لتحديث البيانات
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          // العودة مرة واحدة فقط: خروج من WebView
          // سيتم تحديث البيانات في packages_view وسيتم الانتقال من هناك
          Navigator.of(context).pop(); // خروج من WebView
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحة الدفع'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.url))),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                useOnLoadResource: true,
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
    );
  }
}