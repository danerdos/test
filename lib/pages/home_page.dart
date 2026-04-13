import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../models/catalog_summary.dart';
import '../services/api_service.dart';
import '../services/favorites_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/book_card.dart';
import '../widgets/language_switch_button.dart';
import 'auth_page.dart';
import 'book_details_page.dart';
import 'user_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_HomeCatalogData> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
  }

  Future<_HomeCatalogData> _loadHomeData() async {
    final results = await Future.wait<dynamic>([
      ApiService.getBooks(),
      ApiService.getCatalogSummary(),
    ]);

    return _HomeCatalogData(
      books: results[0] as List<Book>,
      summary: results[1] as CatalogSummary,
    );
  }

  Future<void> _reloadBooks() async {
    final future = _loadHomeData();
    setState(() => _homeDataFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favoritesController = FavoritesController.of(context);

    return SafeArea(
      child: ValueListenableBuilder<Set<int>>(
        valueListenable: favoritesController,
        builder: (context, favoriteIds, _) {
          return FutureBuilder<_HomeCatalogData>(
            future: _homeDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l10n.failedToLoadBooks}\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _reloadBooks,
                          child: Text(l10n.exploreCatalog),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data;
              final books = data?.books ?? const <Book>[];
              final summary = data?.summary ??
                  const CatalogSummary(
                    totalBooks: 0,
                    readableBooks: 0,
                    englishBooks: 0,
                    arabicBooks: 0,
                  );
              final readableBooks = books.where((book) => book.isReadable).toList();
              final englishBooks = books.where((book) => !book.isArabic).toList();
              final arabicBooks = books.where((book) => book.isArabic).toList();
              final featuredBook = readableBooks.isNotEmpty
                  ? readableBooks.first
                  : (books.isNotEmpty ? books.first : null);

              return RefreshIndicator(
                onRefresh: _reloadBooks,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
                  children: [
                    _header(context),
                    const SizedBox(height: 24),
                    if (books.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 56),
                        child: Center(
                          child: Text(
                            l10n.noBooksAvailable,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else ...[
                      _catalogOverview(
                        context,
                        summary: summary,
                      ),
                      const SizedBox(height: 24),
                      if (featuredBook != null) ...[
                        _SectionHeader(
                          title: l10n.featuredPick,
                          subtitle: l10n.availableForReading,
                        ),
                        const SizedBox(height: 12),
                        BookCard(
                          book: featuredBook,
                          large: true,
                          isFavorited: favoriteIds.contains(featuredBook.id),
                          onFavoriteTap: () =>
                              favoritesController.toggle(featuredBook.id),
                          onTap: () => _openBook(featuredBook),
                        ),
                        const SizedBox(height: 28),
                      ],
                      _SectionHeader(
                        title: l10n.availableToRead,
                        subtitle: l10n.availableForReading,
                      ),
                      const SizedBox(height: 12),
                      _horizontalBooks(
                        readableBooks,
                        favoriteIds: favoriteIds,
                        favoritesController: favoritesController,
                      ),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: l10n.englishLibrary,
                        subtitle: '${summary.englishBooks} ${l10n.booksLabel}',
                      ),
                      const SizedBox(height: 12),
                      _horizontalBooks(
                        englishBooks.take(12).toList(),
                        favoriteIds: favoriteIds,
                        favoritesController: favoritesController,
                      ),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: l10n.arabicLibrary,
                        subtitle: '${summary.arabicBooks} ${l10n.booksLabel}',
                      ),
                      const SizedBox(height: 12),
                      _horizontalBooks(
                        arabicBooks,
                        favoriteIds: favoriteIds,
                        favoritesController: favoritesController,
                      ),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: l10n.curatedClassics,
                        subtitle: l10n.catalogOverview,
                      ),
                      const SizedBox(height: 12),
                      _gridBooks(
                        books.take(8).toList(),
                        favoriteIds: favoriteIds,
                        favoritesController: favoritesController,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Books Library',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Row(
          children: [
            const LanguageSwitchButton(),
            const SizedBox(width: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserPage()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _catalogOverview(
    BuildContext context, {
    required CatalogSummary summary,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: tileWidth,
              child: _StatCard(
                value: '${summary.totalBooks}',
                label: context.l10n.booksLabel,
                tone: AppColors.mutedBlue,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: _StatCard(
                value: '${summary.readableBooks}',
                label: context.l10n.availableNow,
                tone: AppColors.mutedGreen,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: _StatCard(
                value: '${summary.englishBooks}',
                label: context.l10n.languageEnglish,
                tone: AppColors.mutedGold,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: _StatCard(
                value: '${summary.arabicBooks}',
                label: context.l10n.languageArabic,
                tone: AppColors.mutedBlue,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _horizontalBooks(
    List<Book> books, {
    required Set<int> favoriteIds,
    required FavoritesController favoritesController,
  }) {
    if (books.isEmpty) {
      return const _EmptyBooksState();
    }

    return SizedBox(
      height: 330,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            isFavorited: favoriteIds.contains(book.id),
            onFavoriteTap: () => favoritesController.toggle(book.id),
            onTap: () => _openBook(book),
          );
        },
      ),
    );
  }

  Widget _gridBooks(
    List<Book> books, {
    required Set<int> favoriteIds,
    required FavoritesController favoritesController,
  }) {
    if (books.isEmpty) {
      return const _EmptyBooksState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          isFavorited: favoriteIds.contains(book.id),
          onFavoriteTap: () => favoritesController.toggle(book.id),
          onTap: () => _openBook(book),
        );
      },
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color tone;

  const _StatCard({
    required this.value,
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBooksState extends StatelessWidget {
  const _EmptyBooksState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        context.l10n.noBooksAvailable,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _HomeCatalogData {
  final List<Book> books;
  final CatalogSummary summary;

  const _HomeCatalogData({
    required this.books,
    required this.summary,
  });
}
