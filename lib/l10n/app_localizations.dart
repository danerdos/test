import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context.');
    return localizations!;
  }

  static const _values = <String, Map<String, String>>{
    'en': {
      'language': 'العربية',
      'home': 'Home',
      'libraryTitle': 'Curated Library',
      'librarySubtitle':
          'Famous books in English and Arabic, with two titles ready to read inside the app today.',
      'availableToRead': 'Available to Read',
      'availableForReading': 'Ready inside the app now',
      'catalogOverview': 'Catalog Overview',
      'curatedClassics': 'Curated classics',
      'englishLibrary': 'English Library',
      'arabicLibrary': 'Arabic Library',
      'featuredPick': 'Featured Pick',
      'all': 'All',
      'bookShortcuts': 'Book Shortcuts',
      'fullBooks': 'Full Books',
      'shortcuts': 'Shortcuts',
      'todaysTitle': "Today's Title",
      'mostFamousBooks': 'Most Famous Books',
      'noBooksFound': 'No books found in the API yet.',
      'noBooksAvailable': 'No books available.',
      'failedToLoadBooks': 'Failed to load books.',
      'bookId': 'Book ID',
      'author': 'Author',
      'languageLabel': 'Language',
      'chapters': 'Chapters',
      'description': 'Description',
      'aboutThisBook': 'About this book',
      'textBook': 'Text Book',
      'readInApp': 'Read in App',
      'noDescriptionAvailable': 'No description available.',
      'noAdditionalInfo': 'No additional information available.',
      'failedToLoadChapters': 'Failed to load chapters.',
      'noChaptersForBook': 'No chapters available for this book.',
      'chapter': 'Chapter',
      'failedToLoadChapterPages': 'Failed to load chapter pages.',
      'noPagesForChapter': 'No pages found for this chapter.',
      'page': 'Page',
      'failedToLoadBookText': 'Failed to load book text.',
      'noReadableContent': 'No readable content found for this book.',
      'readAloud': 'Read aloud',
      'listenToChapter': 'Audio available per chapter',
      'preparingAudio':
          'Preparing chapter audio. This can take a few seconds the first time.',
      'audioReady': 'Audio is ready for this chapter.',
      'pauseAudio': 'Pause',
      'resumeAudio': 'Resume',
      'stopAudio': 'Stop',
      'failedToLoadChapterAudio': 'Failed to load chapter audio.',
      'tapToListen': 'Tap read aloud to generate and play chapter audio.',
      'nowPlaying': 'Now playing chapter audio.',
      'paragraphs': 'paragraphs',
      'voice': 'Voice',
      'selectedVoice': 'Selected voice',
      'search': 'Search',
      'searchPage': 'Search Page',
      'searchHint': 'Search by title or author',
      'noSearchResults': 'No books match your search.',
      'savedBooks': 'Favorites',
      'readyToRead': 'Ready to Read',
      'favorites': 'Favorites',
      'addToFavorites': 'Add to favorites',
      'removeFromFavorites': 'Remove from favorites',
      'noFavoritesYet': 'No favorite books yet.',
      'favoriteHint': 'Tap the heart on any book to keep it here.',
      'profile': 'Profile',
      'notLoggedIn': 'Not logged in',
      'email': 'Email',
      'uid': 'UID',
      'logout': 'Logout',
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'password': 'Password',
      'createAccount': 'Create an account',
      'alreadyHaveAccount': 'Already have an account?',
      'previewOnly': 'Preview Only',
      'availableNow': 'Available now',
      'comingSoon': 'Coming soon',
      'catalogOnly': 'Catalog only for now',
      'languageEnglish': 'English',
      'languageArabic': 'Arabic',
      'chaptersCount': 'Chapters',
      'pagesCount': 'Pages',
      'exploreCatalog': 'Explore Catalog',
      'booksLabel': 'books',
      'catalogNote':
          'This title is in the catalog, but full reading is not available in the app yet.',
    },
    'ar': {
      'language': 'English',
      'home': 'الرئيسية',
      'libraryTitle': 'المكتبة المختارة',
      'librarySubtitle':
          'أشهر الكتب بالإنجليزية والعربية، مع كتابين متاحين للقراءة الآن داخل التطبيق.',
      'availableToRead': 'متاح للقراءة',
      'availableForReading': 'جاهز للقراءة داخل التطبيق',
      'catalogOverview': 'نظرة على المكتبة',
      'curatedClassics': 'مختارات كلاسيكية',
      'englishLibrary': 'المكتبة الإنجليزية',
      'arabicLibrary': 'المكتبة العربية',
      'featuredPick': 'اختيار مميز',
      'all': 'الكل',
      'bookShortcuts': 'مختصرات الكتب',
      'fullBooks': 'الكتب الكاملة',
      'shortcuts': 'المختصرات',
      'todaysTitle': 'عنوان اليوم',
      'mostFamousBooks': 'أشهر الكتب',
      'noBooksFound': 'لا توجد كتب من الـ API حالياً.',
      'noBooksAvailable': 'لا توجد كتب متاحة.',
      'failedToLoadBooks': 'فشل تحميل الكتب.',
      'bookId': 'رقم الكتاب',
      'author': 'المؤلف',
      'languageLabel': 'اللغة',
      'chapters': 'الفصول',
      'description': 'الوصف',
      'aboutThisBook': 'عن هذا الكتاب',
      'textBook': 'نص الكتاب',
      'readInApp': 'اقرأ داخل التطبيق',
      'noDescriptionAvailable': 'لا يوجد وصف متاح.',
      'noAdditionalInfo': 'لا توجد معلومات إضافية متاحة.',
      'failedToLoadChapters': 'فشل تحميل الفصول.',
      'noChaptersForBook': 'لا توجد فصول لهذا الكتاب.',
      'chapter': 'الفصل',
      'failedToLoadChapterPages': 'فشل تحميل صفحات الفصل.',
      'noPagesForChapter': 'لا توجد صفحات لهذا الفصل.',
      'page': 'الصفحة',
      'failedToLoadBookText': 'فشل تحميل نص الكتاب.',
      'noReadableContent': 'لا يوجد محتوى قابل للقراءة لهذا الكتاب.',
      'readAloud': 'اقرأ بصوت',
      'listenToChapter': 'الصوت متاح لكل فصل',
      'preparingAudio':
          'يجري تحضير صوت الفصل. قد يستغرق ذلك بضع ثوانٍ في أول مرة.',
      'audioReady': 'الصوت جاهز لهذا الفصل.',
      'pauseAudio': 'إيقاف مؤقت',
      'resumeAudio': 'متابعة',
      'stopAudio': 'إيقاف',
      'failedToLoadChapterAudio': 'فشل تحميل صوت الفصل.',
      'tapToListen': 'اضغط على اقرأ بصوت لإنشاء صوت الفصل وتشغيله.',
      'nowPlaying': 'يتم تشغيل صوت الفصل الآن.',
      'paragraphs': 'فقرات',
      'voice': 'الصوت',
      'selectedVoice': 'الصوت المحدد',
      'search': 'البحث',
      'searchPage': 'صفحة البحث',
      'searchHint': 'ابحث بالعنوان أو المؤلف',
      'noSearchResults': 'لا توجد كتب تطابق البحث.',
      'savedBooks': 'المفضلة',
      'readyToRead': 'جاهز للقراءة',
      'favorites': 'المفضلة',
      'addToFavorites': 'أضف إلى المفضلة',
      'removeFromFavorites': 'إزالة من المفضلة',
      'noFavoritesYet': 'لا توجد كتب مفضلة بعد.',
      'favoriteHint': 'اضغط على القلب في أي كتاب ليظهر هنا.',
      'profile': 'الملف الشخصي',
      'notLoggedIn': 'لم يتم تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'uid': 'المعرف',
      'logout': 'تسجيل الخروج',
      'signIn': 'تسجيل الدخول',
      'signUp': 'إنشاء حساب',
      'password': 'كلمة المرور',
      'createAccount': 'إنشاء حساب',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟',
      'previewOnly': 'عرض فقط',
      'availableNow': 'متاح الآن',
      'comingSoon': 'قريباً',
      'catalogOnly': 'متاح في الفهرس فقط حالياً',
      'languageEnglish': 'إنجليزي',
      'languageArabic': 'العربية',
      'chaptersCount': 'الفصول',
      'pagesCount': 'الصفحات',
      'exploreCatalog': 'استكشف المكتبة',
      'booksLabel': 'كتاب',
      'catalogNote':
          'هذا العنوان موجود في الفهرس، لكن النص الكامل غير متاح للقراءة داخل التطبيق بعد.',
    },
  };

  String get _code =>
      _values.containsKey(locale.languageCode) ? locale.languageCode : 'en';

  String _text(String key) => _values[_code]![key] ?? _values['en']![key]!;

  String get language => _text('language');
  String get home => _text('home');
  String get libraryTitle => _text('libraryTitle');
  String get librarySubtitle => _text('librarySubtitle');
  String get availableToRead => _text('availableToRead');
  String get availableForReading => _text('availableForReading');
  String get catalogOverview => _text('catalogOverview');
  String get curatedClassics => _text('curatedClassics');
  String get englishLibrary => _text('englishLibrary');
  String get arabicLibrary => _text('arabicLibrary');
  String get featuredPick => _text('featuredPick');
  String get all => _text('all');
  String get bookShortcuts => _text('bookShortcuts');
  String get fullBooks => _text('fullBooks');
  String get shortcuts => _text('shortcuts');
  String get todaysTitle => _text('todaysTitle');
  String get mostFamousBooks => _text('mostFamousBooks');
  String get noBooksFound => _text('noBooksFound');
  String get noBooksAvailable => _text('noBooksAvailable');
  String get failedToLoadBooks => _text('failedToLoadBooks');
  String get bookId => _text('bookId');
  String get author => _text('author');
  String get languageLabel => _text('languageLabel');
  String get chapters => _text('chapters');
  String get description => _text('description');
  String get aboutThisBook => _text('aboutThisBook');
  String get textBook => _text('textBook');
  String get readInApp => _text('readInApp');
  String get noDescriptionAvailable => _text('noDescriptionAvailable');
  String get noAdditionalInfo => _text('noAdditionalInfo');
  String get failedToLoadChapters => _text('failedToLoadChapters');
  String get noChaptersForBook => _text('noChaptersForBook');
  String get chapter => _text('chapter');
  String get failedToLoadChapterPages => _text('failedToLoadChapterPages');
  String get noPagesForChapter => _text('noPagesForChapter');
  String get page => _text('page');
  String get failedToLoadBookText => _text('failedToLoadBookText');
  String get noReadableContent => _text('noReadableContent');
  String get readAloud => _text('readAloud');
  String get listenToChapter => _text('listenToChapter');
  String get preparingAudio => _text('preparingAudio');
  String get audioReady => _text('audioReady');
  String get pauseAudio => _text('pauseAudio');
  String get resumeAudio => _text('resumeAudio');
  String get stopAudio => _text('stopAudio');
  String get failedToLoadChapterAudio => _text('failedToLoadChapterAudio');
  String get tapToListen => _text('tapToListen');
  String get nowPlaying => _text('nowPlaying');
  String get paragraphs => _text('paragraphs');
  String get voice => _text('voice');
  String get selectedVoice => _text('selectedVoice');
  String get search => _text('search');
  String get searchPage => _text('searchPage');
  String get searchHint => _text('searchHint');
  String get noSearchResults => _text('noSearchResults');
  String get savedBooks => _text('savedBooks');
  String get readyToRead => _text('readyToRead');
  String get favorites => _text('favorites');
  String get addToFavorites => _text('addToFavorites');
  String get removeFromFavorites => _text('removeFromFavorites');
  String get noFavoritesYet => _text('noFavoritesYet');
  String get favoriteHint => _text('favoriteHint');
  String get profile => _text('profile');
  String get notLoggedIn => _text('notLoggedIn');
  String get email => _text('email');
  String get uid => _text('uid');
  String get logout => _text('logout');
  String get signIn => _text('signIn');
  String get signUp => _text('signUp');
  String get password => _text('password');
  String get createAccount => _text('createAccount');
  String get alreadyHaveAccount => _text('alreadyHaveAccount');
  String get previewOnly => _text('previewOnly');
  String get availableNow => _text('availableNow');
  String get comingSoon => _text('comingSoon');
  String get catalogOnly => _text('catalogOnly');
  String get languageEnglish => _text('languageEnglish');
  String get languageArabic => _text('languageArabic');
  String get chaptersCount => _text('chaptersCount');
  String get pagesCount => _text('pagesCount');
  String get exploreCatalog => _text('exploreCatalog');
  String get booksLabel => _text('booksLabel');
  String get catalogNote => _text('catalogNote');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
