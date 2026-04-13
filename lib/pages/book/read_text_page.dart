import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book.dart';
import '../../models/book_page.dart';
import '../../models/chapter.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/language_switch_button.dart';

class ReadTextPage extends StatelessWidget {
  final Book book;

  const ReadTextPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isArabicBook = book.isArabic;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(book.title),
        actions: const [LanguageSwitchButton()],
      ),
      body: FutureBuilder<Map<Chapter, List<BookPage>>>(
        future: ApiService.getBookContent(book.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${l10n.failedToLoadBookText}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          final content = snapshot.data ?? const <Chapter, List<BookPage>>{};
          if (content.isEmpty) {
            return Center(
              child: Text(
                l10n.noReadableContent,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final chapters = content.entries.toList()
            ..sort(
              (a, b) => a.key.chapterNumber.compareTo(b.key.chapterNumber),
            );

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final entry = chapters[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.chapter} ${entry.key.chapterNumber}: ${entry.key.title}',
                      textDirection: _containsArabic(entry.key.title)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      textAlign: _containsArabic(entry.key.title)
                          ? TextAlign.right
                          : TextAlign.left,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...entry.value.map(
                      (page) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          page.content,
                          textDirection: isArabicBook
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          textAlign: isArabicBook
                              ? TextAlign.right
                              : TextAlign.left,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.7,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
