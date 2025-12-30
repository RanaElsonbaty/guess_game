# OTP Authentication System

## Overview
نظام المصادقة باستخدام رمز التحقق (OTP) لتسجيل الدخول.

## Flow
1. **OTP View** (`/otp`) - إدخال رقم الهاتف وإرسال رمز التحقق
2. **OTP Verify View** (`/otp_verify`) - إدخال رمز التحقق (6 حقول منفصلة)
3. **Login View** - تسجيل الدخول التلقائي وتوجيه حسب الاشتراك

## API Endpoints

### Generate OTP
```http
POST /auth/otp/generate
Content-Type: application/json

{
  "phone": "50000006",
  "take_type": "login"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء رمز التحقق بنجاح",
  "code": 200,
  "data": {
    "expires_at": "2025-12-29T09:22:08.486469Z"
  },
  "meta_data": []
}
```

### Verify OTP
```http
POST /auth/otp/verify
Content-Type: application/json

{
  "phone": "50000006",
  "otp": "123456",
  "take_type": "login"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم التحقق من رمز التحقق بنجاح",
  "code": 200,
  "data": null,
  "meta_data": []
}
```

### Login with OTP
```http
POST /auth/login
Content-Type: application/json

{
  "phone": "50000006",
  "otp": "123456",
  "login_type": "otp"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "code": 200,
  "data": {
    "user": {
      "id": 17,
      "name": "rana",
      "phone": "50000006",
      "phone_verified_at": "2025-12-29T09:08:51.000000Z",
      "email": "rana22@khamine.com",
      "email_verified_at": null,
      "image": null,
      "address": null,
      "last_login_at": "2025-12-29T09:19:16.000000Z",
      "status": "active",
      "deleted_at": null,
      "created_at": "2025-12-29T09:04:51.000000Z",
      "updated_at": "2025-12-29T09:19:16.000000Z",
      "subscription": null
    },
    "token": "22|GEnqu5KlVBJ8O7MHl449olLhpVaMor7Q4e00NPRSbfa5205c"
  },
  "meta_data": []
}
```

## Features

### 6 Separate PIN Fields
- كل حقل يقبل رقم واحد فقط
- الانتقال التلقائي بين الحقول
- التحقق التلقائي عند إكمال جميع الحقول
- تصميم جميل مع shadows وألوان متدرجة

### Auto Navigation
- الانتقال التلقائي من OTP إلى Verify
- الانتقال التلقائي من Verify إلى Login عند النجاح
- التعامل مع الأخطاء وعرض رسائل مناسبة

### Resend Functionality
- إمكانية إعادة إرسال رمز التحقق
- منع إعادة الإرسال أثناء التحميل

### Error Handling
- التعامل مع أخطاء الشبكة
- التعامل مع أخطاء التحقق
- رسائل خطأ واضحة للمستخدم

## Usage

1. انتقل إلى صفحة OTP من intro
2. أدخل رقم الهاتف واضغط "إرسال رمز التحقق"
3. سيتم توجيهك تلقائياً إلى صفحة إدخال الرمز
4. أدخل الرمز في الحقول الـ 6 (سيتم الانتقال تلقائياً)
5. سيتم التحقق والدخول تلقائياً

## Future Enhancement

### Pinput Integration
لتحسين تجربة إدخال OTP، يمكن استخدام package `pinput`:

1. قم بتثبيت الـ package:
```bash
flutter pub get
```

2. فعل الـ import في `otp_verify_view.dart`
3. استبدل الـ Row من TextFields بـ Pinput widget

ملف `pinput_otp_input.dart` يحتوي على الكود الجاهز للاستخدام.

