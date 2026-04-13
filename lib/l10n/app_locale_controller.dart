import 'package:flutter/material.dart';

class AppLocaleController extends ValueNotifier<Locale> {
  AppLocaleController() : super(const Locale('en'));

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AppLocaleScope>();
    assert(scope != null, 'AppLocaleController is not available in context.');
    return scope!.controller;
  }

  void setLocale(Locale locale) {
    value = locale;
  }

  void toggle() {
    value = value.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
  }
}

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  final AppLocaleController controller;

  const AppLocaleScope({
    super.key,
    required this.controller,
    required super.child,
  }) : super(notifier: controller);

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return controller != oldWidget.controller ||
        controller.value != oldWidget.controller.value;
  }
}

class _AppLocaleScope extends AppLocaleScope {
  const _AppLocaleScope({required super.controller, required super.child});
}

Widget buildAppLocaleScope({
  required AppLocaleController controller,
  required Widget child,
}) {
  return _AppLocaleScope(controller: controller, child: child);
}
