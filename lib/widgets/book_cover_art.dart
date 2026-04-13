import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';

class BookCoverArt extends StatelessWidget {
  final Book book;
  final double height;
  final BorderRadius borderRadius;
  final bool detailed;

  const BookCoverArt({
    super.key,
    required this.book,
    required this.height,
    required this.borderRadius,
    this.detailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = _paletteFor(book);
    final textDirection = book.isArabic ? TextDirection.rtl : TextDirection.ltr;
    final textAlign = book.isArabic ? TextAlign.right : TextAlign.left;
    final availabilityLabel = book.isReadable
        ? l10n.availableNow
        : l10n.previewOnly;
    final languageLabel = book.isArabic
        ? l10n.languageArabic
        : l10n.languageEnglish;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -8,
              child: Transform.rotate(
                angle: math.pi / 8,
                child: Text(
                  _monogram(book.title),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.12),
                    fontSize: detailed ? 96 : 72,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -24,
              bottom: -36,
              child: Container(
                width: detailed ? 160 : 120,
                height: detailed ? 160 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(detailed ? 18 : 14),
              child: Column(
                crossAxisAlignment: book.isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: book.isArabic
                        ? WrapAlignment.end
                        : WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        label: languageLabel,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                      ),
                      _Badge(
                        label: availabilityLabel,
                        backgroundColor:
                            (book.isReadable
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withValues(alpha: 0.92),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    book.title,
                    textDirection: textDirection,
                    textAlign: textAlign,
                    maxLines: detailed ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: detailed ? 28 : 20,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    textDirection: textDirection,
                    textAlign: textAlign,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: detailed ? 15 : 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Color> _paletteFor(Book book) {
    final palettes = <List<Color>>[
      const [Color(0xFF12324A), Color(0xFF35678D)],
      const [Color(0xFF4F2A2A), Color(0xFFB06749)],
      const [Color(0xFF173C35), Color(0xFF4E8B72)],
      const [Color(0xFF31254C), Color(0xFF6A5ACD)],
      const [Color(0xFF3F2D1F), Color(0xFFB68851)],
      const [Color(0xFF25324B), Color(0xFF5E7FB6)],
    ];

    final indexSeed =
        book.title.hashCode.abs() +
        (book.isReadable ? 3 : 0) +
        (book.isArabic ? 1 : 0);
    return palettes[indexSeed % palettes.length];
  }

  static String _monogram(String title) {
    final words = title
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .toList();
    if (words.isEmpty) {
      return 'BK';
    }
    return words
        .map((word) => String.fromCharCode(word.runes.first).toUpperCase())
        .join();
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const _Badge({required this.label, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
