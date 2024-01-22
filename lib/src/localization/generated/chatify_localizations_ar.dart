import 'chatify_localizations.dart';

/// The translations for Arabic (`ar`).
class ChatifyLocalizationsAr extends ChatifyLocalizations {
  ChatifyLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get messeges => 'الرسائل';

  @override
  String get message => 'رسالة';

  @override
  String get search => 'بحث';

  @override
  String get delete => 'حذف';

  @override
  String get copy => 'نسخ';

  @override
  String get edit => 'تعديل';

  @override
  String get reply => 'رد';

  @override
  String get confirm => 'تأكيد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'موافق';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get confirmDeleteMessage => 'هل أنت متأكد من حذف الرسالة؟';

  @override
  String get confirmDeleteMessagesTitle => 'هل أنت متأكد من حذف الرسائل؟';

  @override
  String confirmDeleteMessagesCount(int count) {
    return 'حذف $count رسالة';
  }

  @override
  String get selected => 'محددة';

  @override
  String get deleteForAll => 'حذف للجميع';

  @override
  String get confirmDeleteChat => 'هل أنت متأكد من حذف المحادثة؟';

  @override
  String get deleteChat => 'حذف المحادثة';

  @override
  String get selectMedia => 'اختر ملف';

  @override
  String get addCaption => 'إضافة تعليق';

  @override
  String get selectedMedia => 'الملفات المختارة';

  @override
  String get waitingConnection => 'في انتظار الاتصال...';

  @override
  String get connecting => 'جاري الاتصال...';

  @override
  String get online => 'متصل';

  @override
  String get lastSeenRecently => 'آخر ظهور قبل قليل';

  @override
  String get lastSeenJustNow => 'آخر ظهور قبل ثوانٍ';

  @override
  String lastSeenMinutes(int minutes) {
    return 'آخر ظهور منذ $minutes دقيقة';
  }

  @override
  String lastSeenHours(int hours) {
    return 'آخر ظهور منذ $hours ساعة';
  }

  @override
  String lastSeenDays(int days) {
    return 'آخر ظهور منذ $days يوم';
  }

  @override
  String lastSeenWeeks(int weeks) {
    return 'آخر ظهور منذ $weeks أسبوع';
  }

  @override
  String get lastSeenLongTime => 'آخر ظهور منذ وقت طويل';

  @override
  String get me => 'أنا';

  @override
  String get save => 'حفظ';

  @override
  String get savedToGallery => 'تم حفظها في المعرض';

  @override
  String get failedToSave => 'فشل في الحفظ';

  @override
  String get noMessages => 'لا توجد رسائل';

  @override
  String get savedMessages => 'الرسائل المحفوظة';

  @override
  String get chatSupprt => 'الدعم والمساعدة';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get deletedMessage => 'رسالة محذوفة';

  @override
  String get edited => 'تم التعديل';

  @override
  String get sayHi => 'قل مرحبا!';

  @override
  String get noRecentsEmojis => 'لا توجد رموز تعبيرية مستخدمة مؤخرًا';

  @override
  String get member => 'شخص';

  @override
  String get slideToCancel => 'اسحب للإلغاء';

  @override
  String get to => 'إلى: ';

  @override
  String get imageMessage => 'صورة';

  @override
  String get voiceMessage => 'رسالة صوتية';

  @override
  String get unSuppprtedMessage => 'رسالة غير مدعومة';

  @override
  String get deletedAccount => 'حساب محذوف';
}
