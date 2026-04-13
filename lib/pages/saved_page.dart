import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../services/favorites_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/book_card.dart';
import '../widgets/language_switch_button.dart';
import 'book_details_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late Future<List<Book>> _booksFuture;

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
        title: Text(l10n.savedBooks),
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

              final books = (snapshot.data ?? const <Book>[])
                  .where((book) => favoriteIds.contains(book.id))
                  .toList();

              if (books.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_border_rounded,
                          size: 40,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noFavoritesYet,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.favoriteHint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                itemCount: books.length,
                separatorBuilder: (_, index) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return BookCard(
                    book: book,
                    large: true,
                    isFavorited: true,
                    onFavoriteTap: () => favoritesController.toggle(book.id),
                    onTap: () => _openBook(book),
                  );
                },
              );
            },
          );
        },
      ),
    );
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
