import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'favorite_book_ids';

Future<Set<int>> loadFavoriteIds() async {
  final prefs = await SharedPreferences.getInstance();
  final rawIds = prefs.getStringList(_storageKey) ?? const <String>[];
  return rawIds.map(int.tryParse).whereType<int>().toSet();
}

Future<void> saveFavoriteIds(Set<int> ids) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _storageKey,
    ids.map((id) => id.toString()).toList(),
  );
}
