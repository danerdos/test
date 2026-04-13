// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

const _storageKey = 'favorite_book_ids';

Future<Set<int>> loadFavoriteIds() async {
  final rawValue = html.window.localStorage[_storageKey];
  if (rawValue == null || rawValue.trim().isEmpty) {
    return <int>{};
  }

  return rawValue
      .split(',')
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .toSet();
}

Future<void> saveFavoriteIds(Set<int> ids) async {
  html.window.localStorage[_storageKey] = ids.join(',');
}
