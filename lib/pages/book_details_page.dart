import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../services/favorites_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/book_cover_art.dart';
import '../widgets/language_switch_button.dart';
import 'book/chapter_page.dart';
import 'book/read_text_page.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late final Future<List<Chapter>> _chaptersFuture;

  Book get book => widget.book;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = book.isReadable
        ? ApiService.getChapters(book.id)
        : Future.value(const <Chapter>[]);
  }

  @override
  Widget build(BuildContext context) {
    final favoritesController = FavoritesController.of(context);

    return ValueListenableBuilder<Set<int>>(
      valueListenable: favoritesController,
      builder: (context, favoriteIds, _) {
        final isFavorited = favoriteIds.contains(book.id);

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _handle(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const LanguageSwitchButton(),
                      const Spacer(),
                      IconButton.filledTonal(
                        onPressed: () => favoritesController.toggle(book.id),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.card,
                          foregroundColor:
                              isFavorited ? AppColors.accent : AppColors.primary,
                        ),
                        icon: Icon(
                          isFavorited
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BookCoverArt(
                    book: book,
                    height: 300,
                    detailed: true,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  const SizedBox(height: 20),
                  _statusChips(context),
                  const SizedBox(height: 18),
                  _primaryAction(context),
                  const SizedBox(height: 24),
                  _statsRow(context),
                  const SizedBox(height: 24),
                  if (book.isReadable) ...[
                    _chaptersSection(context),
                    const SizedBox(height: 24),
                  ] else ...[
                    _catalogNote(context),
                    const SizedBox(height: 24),
                  ],
                  _descriptionSection(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _statusChips(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(
          label: book.isReadable ? l10n.availableNow : l10n.previewOnly,
          tone: book.isReadable ? AppColors.mutedGreen : AppColors.mutedGold,
        ),
        _Chip(
          label: book.isArabic ? l10n.languageArabic : l10n.languageEnglish,
          tone: AppColors.mutedBlue,
        ),
        _Chip(
          label: '${book.chapterCount} ${l10n.chaptersCount}',
          tone: AppColors.mutedBlue,
        ),
        _Chip(
          label: '${book.pageCount} ${l10n.pagesCount}',
          tone: AppColors.mutedGold,
        ),
      ],
    );
  }

  Widget _primaryAction(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            textDirection: book.isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.author,
            textDirection: book.isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          if (book.isReadable)
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReadTextPage(book: book)),
                );
              },
              child: Text(l10n.readInApp),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mutedGold,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.catalogOnly,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: l10n.languageLabel,
            value: book.isArabic ? l10n.languageArabic : l10n.languageEnglish,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: l10n.chaptersCount,
            value: '${book.chapterCount}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(label: l10n.pagesCount, value: '${book.pageCount}'),
        ),
      ],
    );
  }

  Widget _chaptersSection(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<List<Chapter>>(
      future: _chaptersFuture,
      builder: (context, snapshot) {
        final chapters = snapshot.data ?? const <Chapter>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chapters,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (snapshot.connectionState != ConnectionState.done)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.hasError)
              Text(
                '${l10n.failedToLoadChapters}\n${snapshot.error}',
                style: const TextStyle(color: AppColors.textSecondary),
              )
            else if (chapters.isEmpty)
              Text(
                l10n.noChaptersForBook,
                style: const TextStyle(color: AppColors.textSecondary),
              )
            else
              ...chapters.map((chapter) => _chapterCard(context, chapter)),
          ],
        );
      },
    );
  }

  Widget _chapterCard(BuildContext context, Chapter chapter) {
    final l10n = context.l10n;
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(chapter.title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChapterPage(chapter: chapter)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.mutedBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${l10n.chapter} ${chapter.chapterNumber}: ${chapter.title}',
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _catalogNote(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        context.l10n.catalogNote,
        textDirection: book.isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.55),
      ),
    );
  }

  Widget _descriptionSection(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.description,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            book.description.isEmpty
                ? l10n.noDescriptionAvailable
                : book.description,
            textDirection: book.isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color tone;

  const _Chip({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
