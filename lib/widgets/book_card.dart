import 'package:flutter/material.dart';

import '../models/book.dart';
import '../theme/app_colors.dart';
import 'book_cover_art.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool large;
  final VoidCallback onTap;
  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.large = false,
    this.isFavorited = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection = book.isArabic ? TextDirection.rtl : TextDirection.ltr;
    final textAlign = book.isArabic ? TextAlign.right : TextAlign.left;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: large ? double.infinity : 184,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  BookCoverArt(
                    book: book,
                    height: large ? 250 : 178,
                    detailed: large,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  if (onFavoriteTap != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onFavoriteTap,
                          borderRadius: BorderRadius.circular(999),
                          child: Ink(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Icon(
                              isFavorited
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                book.title,
                maxLines: large ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                textDirection: textDirection,
                textAlign: textAlign,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: large ? 20 : 16,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: textDirection,
                textAlign: textAlign,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (large) ...[
                const SizedBox(height: 12),
                Text(
                  book.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textDirection: textDirection,
                  textAlign: textAlign,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaPill(label: '${book.chapterCount} ch'),
                    _MetaPill(label: '${book.pageCount} pg'),
                    _MetaPill(label: book.languageCodeLabel),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;

  const _MetaPill({required this.label});

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
