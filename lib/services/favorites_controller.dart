import 'package:flutter/material.dart';
import 'favorites_storage_stub.dart'
    if (dart.library.html) 'favorites_storage_web.dart'
    if (dart.library.io) 'favorites_storage_io.dart'
    as storage;

class FavoritesController extends ValueNotifier<Set<int>> {
  FavoritesController._() : super(const <int>{});

  static final FavoritesController instance = FavoritesController._();

  static FavoritesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FavoritesScope>();
    assert(scope != null, 'FavoritesController is not available in context.');
    return scope!.controller;
  }

  Future<void> load() async {
    final ids = await storage.loadFavoriteIds();
    value = Set<int>.unmodifiable(ids);
  }

  bool contains(int bookId) => value.contains(bookId);

  Future<void> toggle(int bookId) async {
    final updated = Set<int>.from(value);
    if (!updated.add(bookId)) {
      updated.remove(bookId);
    }

    value = Set<int>.unmodifiable(updated);
    await storage.saveFavoriteIds(updated);
  }
}

class FavoritesScope extends InheritedNotifier<FavoritesController> {
  final FavoritesController controller;

  const FavoritesScope({
    super.key,
    required this.controller,
    required super.child,
  }) : super(notifier: controller);

  @override
  bool updateShouldNotify(FavoritesScope oldWidget) {
    return controller != oldWidget.controller ||
        controller.value != oldWidget.controller.value;
  }
}

class _FavoritesScope extends FavoritesScope {
  const _FavoritesScope({required super.controller, required super.child});
}

Widget buildFavoritesScope({
  required FavoritesController controller,
  required Widget child,
}) {
  return _FavoritesScope(controller: controller, child: child);
}
