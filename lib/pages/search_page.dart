import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../services/favorites_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/book_cover_art.dart';
import '../widgets/language_switch_button.dart';
import 'book_details_page.dart';

enum _SearchFilter { all, readable, english, arabic }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Book>> _booksFuture;
  String _query = '';
  _SearchFilter _filter = _SearchFilter.all;

  @override
  void initState() {
    super.initState();
    _booksFuture = ApiService.getBooks();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favoritesController = FavoritesController.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n.search),
        actions: const [LanguageSwitchButton()],
      ),
      body: ValueListenableBuilder<Set<int>>(
        valueListenable: favoritesController,
        builder: (context, favoriteIds, _) {
          return FutureBuilder<List<Book>>(
            future: _booksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '${l10n.failedToLoadBooks}\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              final books = snapshot.data ?? const <Book>[];
              final filteredBooks = books
                  .where(_matchesFilter)
                  .where(_matchesQuery)
                  .toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                children: [
                  _SearchField(
                    hintText: l10n.searchHint,
                    onChanged: (value) => setState(() => _query = value.trim()),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChipButton(
                        label: l10n.all,
                        selected: _filter == _SearchFilter.all,
                        onTap: () => setState(() => _filter = _SearchFilter.all),
                      ),
                      _FilterChipButton(
                        label: l10n.availableNow,
                        selected: _filter == _SearchFilter.readable,
                        onTap: () =>
                            setState(() => _filter = _SearchFilter.readable),
                      ),
                      _FilterChipButton(
                        label: l10n.languageEnglish,
                        selected: _filter == _SearchFilter.english,
                        onTap: () =>
                            setState(() => _filter = _SearchFilter.english),
                      ),
                      _FilterChipButton(
                        label: l10n.languageArabic,
                        selected: _filter == _SearchFilter.arabic,
                        onTap: () =>
                            setState(() => _filter = _SearchFilter.arabic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (filteredBooks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          l10n.noSearchResults,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...filteredBooks.map(
                      (book) => _SearchResultTile(
                        book: book,
                        isFavorited: favoriteIds.contains(book.id),
                        onFavoriteTap: () => favoritesController.toggle(book.id),
                        onTap: () => _openBook(book),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _matchesFilter(Book book) {
    switch (_filter) {
      case _SearchFilter.all:
        return true;
      case _SearchFilter.readable:
        return book.isReadable;
      case _SearchFilter.english:
        return !book.isArabic;
      case _SearchFilter.arabic:
        return book.isArabic;
    }
  }

  bool _matchesQuery(Book book) {
    if (_query.isEmpty) {
      return true;
    }

    final query = _query.toLowerCase();
    return book.title.toLowerCase().contains(query) ||
        book.author.toLowerCase().contains(query);
  }

  void _openBook(Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookDetailsPage(book: book),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Book book;
  final bool isFavorited;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.book,
    required this.isFavorited,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: BookCoverArt(
                    book: book,
                    height: 132,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        textDirection:
                            book.isArabic ? TextDirection.rtl : TextDirection.ltr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.author,
                        textDirection:
                            book.isArabic ? TextDirection.rtl : TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ResultPill(
                            label: book.isReadable
                                ? l10n.availableNow
                                : l10n.previewOnly,
                          ),
                          _ResultPill(
                            label: book.isArabic
                                ? l10n.languageArabic
                                : l10n.languageEnglish,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavoriteTap,
                  icon: Icon(
                    isFavorited
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color:
                        isFavorited ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPill extends StatelessWidget {
  final String label;

  const _ResultPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mutedBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
