# مسبحتي | Tasbih

مشروع Flutter لمسبحة إلكترونية عربية.

## المزايا
- عداد تسبيح مع اهتزاز خفيف.
- تراجع وتصفير مع تأكيد.
- أهداف 33 و99 و100.
- مؤشر تقدم دائري.
- الوضع الليلي والنهاري.
- حفظ العدد والهدف والثيم تلقائيًا باستخدام shared_preferences.
- واجهة RTL وألوان تركواز.

## معلومات التطبيق
- Flutter: 3.47.2 (يُستخدم في سير عمل GitHub Actions)
- Android applicationId: `com.sajid.tasbih`
- Version: `1.0.0+1`

## بناء APK عبر GitHub Actions
1. ارفع محتويات هذا المجلد إلى مستودع GitHub.
2. افتح تبويب **Actions**.
3. اختر **Build Tasbih APK** ثم **Run workflow**.
4. بعد نجاح البناء افتح نتيجة التشغيل ونزّل artifact باسم `tasbih-release-apk`.

يُنشئ سير العمل مجلد Android من جديد باستخدام Flutter 3.47.2 قبل البناء؛ وبذلك يستخدم Android embedding V2 بدل ملفات Android القديمة التي سببت الخطأ.

## البناء محليًا
إذا كان Flutter مثبتًا:

```bash
flutter create --platforms=android --org com.sajid --project-name tasbih .
flutter pub get
flutter build apk --release
```

ملف APK الناتج:
`build/app/outputs/flutter-apk/app-release.apk`
